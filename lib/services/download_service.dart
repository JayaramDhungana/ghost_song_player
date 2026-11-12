import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/song.dart';

class DownloadResult {
  final int totalSongs;
  final int downloadedSongs;
  final int failedSongs;
  final bool isAlreadyDownloaded;
  final String? errorMessage;

  DownloadResult({
    required this.totalSongs,
    required this.downloadedSongs,
    required this.failedSongs,
    this.isAlreadyDownloaded = false,
    this.errorMessage,
  });

  bool get isSuccess => failedSongs == 0 && downloadedSongs == totalSongs;
  bool get hasPartialSuccess => downloadedSongs > 0 && failedSongs > 0;
}

class DownloadService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 25),
    ),
  );
  String? _cachedSavePath;

  Future<String> get _savePath async {
    if (_cachedSavePath != null) return _cachedSavePath!;
    Directory appSupportDir = await getApplicationSupportDirectory();
    if (!await appSupportDir.exists()) {
      await appSupportDir.create(recursive: true);
    }
    _cachedSavePath = appSupportDir.path;
    return _cachedSavePath!;
  }

  // Gets the total size of all songs in bytes safely
  Future<int> _calculateTotalSize(
    List<Song> songsToDownload,
    Function(String) onStatus,
  ) async {
    int totalSize = 0;
    int checked = 0;
  
    // Chunking HEAD requests so we don't spam the server and get blocked
    for (int i = 0; i < songsToDownload.length; i += 10) {
      int end = (i + 10 < songsToDownload.length)
          ? i + 10
          : songsToDownload.length;
      List<Song> chunk = songsToDownload.sublist(i, end);

      await Future.wait(
        chunk.map((song) async {
          try {
            final response = await _dio.head(
              song.audioUrl,
              options: Options(
                receiveTimeout: const Duration(seconds: 5),
                sendTimeout: const Duration(seconds: 5),
              ),
            );
            final contentLength = response.headers.value(
              Headers.contentLengthHeader,
            );
            if (contentLength != null) {
              totalSize += int.tryParse(contentLength) ?? 0;
            }
          } catch (e) {
            // If HEAD request fails/times out, estimate 5MB per song
            totalSize += 5 * 1024 * 1024;
          }
          checked++;
          onStatus('Calculating size... ($checked/${songsToDownload.length})');
        }),
      );
    }
    return totalSize;
  }

  Future<DownloadResult> downloadAllSongs(
    List<Song> songs,
    Function(
      int songsDone,
      int totalSongs,
      int receivedBytes,
      int totalBytes,
      String status,
    )
    onProgress,
  ) async {
    int totalSongs = songs.length;
    String basePath = await _savePath;

    onProgress(0, totalSongs, 0, 0, 'Checking files...');

    // 1. Filter songs that actually need downloading (and clean up 0-byte corrupt files)
    List<Song> songsToDownload = [];
    int alreadyDownloaded = 0;

    for (var song in songs) {
      String fileSavePath = '$basePath/${song.id}.mp3';
      File file = File(fileSavePath);
      if (await file.exists()) {
        try {
          int size = await file.length();
          if (size > 10 * 1024) {
            alreadyDownloaded++;
            continue;
          } else {
            // Delete corrupt / 0-byte file
            await file.delete();
          }
        } catch (_) {}
      }
      songsToDownload.add(song);
    }

    if (songsToDownload.isEmpty) {
      onProgress(
        totalSongs,
        totalSongs,
        0,
        0,
        'All songs are already downloaded!',
      );
      return DownloadResult(
        totalSongs: totalSongs,
        downloadedSongs: totalSongs,
        failedSongs: 0,
        isAlreadyDownloaded: true,
      );
    }

    int downloadedSongs = alreadyDownloaded;
    int failedCount = 0;
    String? lastError;

    // 2. Calculate Total Size
    int totalBytesToDownload = await _calculateTotalSize(songsToDownload, (
      statusText,
    ) {
      onProgress(downloadedSongs, totalSongs, 0, 0, statusText);
    });

    // 3. Start Downloading
    int totalReceivedBytes = 0;
    const int maxConcurrentDownloads = 4;

    // Track bytes for each song to update overall progress accurately
    Map<String, int> receivedBytesPerSong = {};

    for (int i = 0; i < songsToDownload.length; i += maxConcurrentDownloads) {
      int end = (i + maxConcurrentDownloads < songsToDownload.length)
          ? i + maxConcurrentDownloads
          : songsToDownload.length;
      List<Song> currentChunk = songsToDownload.sublist(i, end);

      await Future.wait(
        currentChunk.map((song) async {
          String finalSavePath = '$basePath/${song.id}.mp3';
          String tempSavePath = '$basePath/${song.id}.mp3.tmp';
          File tempFile = File(tempSavePath);
          File finalFile = File(finalSavePath);

          try {
            if (await tempFile.exists()) {
              await tempFile.delete();
            }

            await _dio.download(
              song.audioUrl,
              tempSavePath,
              onReceiveProgress: (received, total) {
                receivedBytesPerSong[song.id] = received;

                // Calculate sum of all currently received bytes
                int currentTotalReceived = receivedBytesPerSong.values.fold(
                  0,
                  (sum, val) => sum + val,
                );

                onProgress(
                  downloadedSongs,
                  totalSongs,
                  totalReceivedBytes + currentTotalReceived,
                  totalBytesToDownload,
                  'Downloading (${downloadedSongs + 1}/$totalSongs)...',
                );
              },
            );

            // Validate temp file before completing
            if (await tempFile.exists() &&
                await tempFile.length() > 10 * 1024) {
              if (await finalFile.exists()) {
                await finalFile.delete();
              }
              await tempFile.rename(finalSavePath);

              totalReceivedBytes += receivedBytesPerSong[song.id] ?? 0;
              receivedBytesPerSong.remove(song.id);
              downloadedSongs++;

              onProgress(
                downloadedSongs,
                totalSongs,
                totalReceivedBytes,
                totalBytesToDownload,
                'Downloading ($downloadedSongs/$totalSongs)...',
              );
            } else {
              throw Exception('Downloaded file is empty or corrupted');
            }
          } catch (e) {
            debugPrint('Error downloading "${song.title}" (${song.id}): $e');
            lastError = e.toString();
            failedCount++;
            receivedBytesPerSong.remove(song.id);
            try {
              if (await tempFile.exists()) await tempFile.delete();
            } catch (_) {}
          }
        }),
      );
    }

    return DownloadResult(
      totalSongs: totalSongs,
      downloadedSongs: downloadedSongs,
      failedSongs: failedCount,
      isAlreadyDownloaded: false,
      errorMessage: lastError,
    );
  }

  Future<String?> getLocalSongPath(String songId) async {
    String basePath = await _savePath;
    String fileSavePath = '$basePath/$songId.mp3';
    File file = File(fileSavePath);
    if (await file.exists()) {
      try {
        if (await file.length() > 10 * 1024) {
          return fileSavePath;
        } else {
          // Remove 0-byte or corrupted file
          await file.delete();
        }
      } catch (_) {}
    }
    return null;
  }
}
