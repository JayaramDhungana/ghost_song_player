import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/music_library.dart';
import '../services/download_service.dart';

class DownloadView extends StatefulWidget {
  const DownloadView({super.key});

  @override
  State<DownloadView> createState() => _DownloadViewState();
}

class _DownloadViewState extends State<DownloadView> with SingleTickerProviderStateMixin {
  final DownloadService _downloadService = DownloadService();
  bool _isDownloading = false;
  double _progress = 0.0;
  int _downloadedCount = 0;
  int _totalCount = 0;
  int _receivedBytes = 0;
  int _totalBytes = 0;
  String _statusText = 'Download Your Library';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _totalCount = MusicLibraryData.songs.length;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _checkStatus();
  }
  
  void _checkStatus() async {
    // Check how many songs are already downloaded
    int count = 0;
    for (var song in MusicLibraryData.songs) {
      if (await _downloadService.getLocalSongPath(song.id) != null) {
        count++;
      }
    }
    if (mounted) {
      setState(() {
        _downloadedCount = count;
        _progress = _totalCount > 0 ? count / _totalCount : 0;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatMB(int bytes) {
    if (bytes == 0) return '0.00 MB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  void _startDownload() async {
    setState(() {
      _isDownloading = true;
      _statusText = 'Preparing download...';
    });

    final result = await _downloadService.downloadAllSongs(
      MusicLibraryData.songs, 
      (downloaded, total, receivedBytes, totalBytes, statusText) {
        if (mounted) {
          setState(() {
            _downloadedCount = downloaded;
            _receivedBytes = receivedBytes;
            _totalBytes = totalBytes;
            _statusText = statusText;
            if (totalBytes > 0) {
              _progress = (receivedBytes / totalBytes).clamp(0.0, 1.0);
            } else if (total > 0) {
              _progress = (downloaded / total).clamp(0.0, 1.0);
            }
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _isDownloading = false;
        _downloadedCount = result.downloadedSongs;
        _progress = _totalCount > 0 
            ? (result.downloadedSongs / _totalCount).clamp(0.0, 1.0) 
            : 0.0;
        _statusText = result.isSuccess 
            ? 'All Set for Offline!' 
            : '${result.downloadedSongs}/$_totalCount songs downloaded';
      });

      if (result.isAlreadyDownloaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('ℹ️ All songs are already downloaded for offline use!', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blue.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 All ${result.totalSongs} songs downloaded successfully!', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.green.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else if (result.hasPartialSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ Downloaded ${result.downloadedSongs}/${result.totalSongs} songs. ${result.failedSongs} failed. Please try again.', 
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '❌ Download failed. Please check your internet connection and try again.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isComplete = _downloadedCount == _totalCount && _totalCount > 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Offline Music', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black,
              Colors.deepPurple.shade900.withOpacity(0.5),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glassmorphism Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            ScaleTransition(
                              scale: _isDownloading ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                              child: Icon(
                                isComplete ? Icons.cloud_done_rounded : Icons.cloud_download_rounded,
                                size: 100,
                                color: isComplete ? Colors.greenAccent : Colors.purpleAccent.shade100,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              isComplete 
                                  ? 'All Set for Offline!' 
                                  : _isDownloading ? _statusText : 'Download Your Library',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isComplete 
                                  ? 'Listen to your music anywhere, anytime without internet.'
                                  : 'Get all $_totalCount songs on your device for uninterrupted offline listening.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.6),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Progress Bar
                            Stack(
                              children: [
                                Container(
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 12,
                                  width: MediaQuery.of(context).size.width * 0.7 * _progress,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.purpleAccent, Colors.blueAccent],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.purpleAccent.withOpacity(0.5),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _isDownloading && _totalBytes > 0 
                                      ? '${_formatMB(_receivedBytes)} / ${_formatMB(_totalBytes)}\n($_downloadedCount/$_totalCount songs)'
                                      : '$_downloadedCount / $_totalCount downloaded',
                                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                                ),
                                Text(
                                  '${(_progress * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Action Button
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: (_isDownloading || isComplete) ? null : _startDownload,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purpleAccent.shade400,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 8,
                                  shadowColor: Colors.purpleAccent.withOpacity(0.5),
                                ),
                                child: _isDownloading
                                    ? const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 20, width: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          ),
                                          SizedBox(width: 12),
                                          Text('Downloading...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        ],
                                      )
                                    : Text(
                                        isComplete ? 'Downloaded' : 'Download Now',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
