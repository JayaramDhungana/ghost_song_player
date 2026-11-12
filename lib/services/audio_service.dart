import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../models/song.dart';
import 'download_service.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  final DownloadService _downloadService = DownloadService();

  List<Song> _playlist = [];

  // Custom index tracker
  int? _currentIndexInternal;
  final StreamController<int?> _currentIndexController =
      StreamController<int?>.broadcast();

  // The dynamically managed audio source
  ConcatenatingAudioSource? _currentPlaylistSource;

  int _relativeIndex =
      0; // Tracks which song in the 3-song window is currently playing
  StreamSubscription? _justAudioIndexSub;

  // LOCK: Prevents race condition when updating the sliding window.
  // When true, index change events from just_audio are ignored.
  bool _isUpdatingWindow = false;

  AudioService() {
    // Listen to just_audio's internal index changes
    _justAudioIndexSub = _player.currentIndexStream.listen(
      (index) {
        // CRITICAL: Ignore index changes while we are updating the window.
        // Without this, insert/remove operations cause fake index shifts
        // that trigger an infinite loop.
        if (_isUpdatingWindow) return;

        if (index != null && _currentPlaylistSource != null) {
          if (index > _relativeIndex) {
            // Moved forward
            _handleIndexChange(isNext: true);
          } else if (index < _relativeIndex) {
            // Moved backward
            _handleIndexChange(isNext: false);
          }
        }
      },
      onError: (Object e) {},
      cancelOnError: false,
    );
  }

  // ============================================================
  // STREAMS
  // ============================================================

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<Duration?> get durationStream => _player.durationStream;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Stream<int?> get currentIndexStream => _currentIndexController.stream;

  // ============================================================
  // PLAYER INFO
  // ============================================================

  bool get isPlaying => _player.playing;

  bool get isLoading =>
      _player.processingState == ProcessingState.loading ||
      _player.processingState == ProcessingState.buffering;

  int? get currentIndex => _currentIndexInternal;

  Duration get position => _player.position;

  Duration? get duration => _player.duration;

  ProcessingState get processingState => _player.processingState;

  List<Song> get playlist => List.unmodifiable(_playlist);

  // ============================================================
  // CURRENT SONG
  // ============================================================

  Song? get currentSong {
    final index = _currentIndexInternal;

    if (index == null || index < 0 || index >= _playlist.length) {
      return null;
    }

    return _playlist[index];
  }

  // ============================================================
  // HELPER: CREATE AUDIO SOURCE
  // ============================================================

  Future<AudioSource> _createSource(Song song) async {
    final audioUrl = song.audioUrl;
    
    final mediaItem = MediaItem(
      id: song.id,
      album: 'Ghost Player',
      title: song.title,
      artist: song.artist,
      artUri: song.coverUrl != null && song.coverUrl!.startsWith('http')
          ? Uri.parse(song.coverUrl!)
          : null,
    );

    if (audioUrl.startsWith('asset://')) {
      return AudioSource.asset(
        audioUrl.replaceFirst('asset://', ''),
        tag: (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) ? null : mediaItem,
      );
    }

    if (!kIsWeb) {
      String? localPath = await _downloadService.getLocalSongPath(song.id);
      if (localPath != null) {
        return AudioSource.uri(Uri.file(localPath), tag: (defaultTargetPlatform == TargetPlatform.windows) ? null : mediaItem);
      }
    }

    if (audioUrl.startsWith('http://') || audioUrl.startsWith('https://')) {
      return AudioSource.uri(Uri.parse(audioUrl), tag: (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) ? null : mediaItem);
    }

    throw ArgumentError('Unsupported audio source: $audioUrl');
  }

  // ============================================================
  // SET PLAYLIST (NO PRELOADING ALL SONGS)
  // ============================================================

  Future<void> setPlaylist(List<Song> songs) async {
    _playlist = List.unmodifiable(songs);

    // Always reset stale state from the previous playlist.
    _currentPlaylistSource = null;
    _setCurrentIndex(null);

    if (kIsWeb || defaultTargetPlatform != TargetPlatform.windows) {
      await _player.stop();
    }
  }

  // ============================================================
  // INTERNAL: HANDLE INDEX CHANGE
  // ============================================================

  Future<void> _handleIndexChange({required bool isNext}) async {
    if (_currentIndexInternal == null || _currentPlaylistSource == null) return;

    // LOCK the window so index stream events are ignored
    _isUpdatingWindow = true;

    try {
      if (isNext) {
        final newIndex = _currentIndexInternal! + 1;
        if (newIndex >= _playlist.length) return; // End of playlist

        _setCurrentIndex(newIndex);

        // If we had a previous song in the window, remove it (index 0).
        if (_relativeIndex > 0) {
          await _currentPlaylistSource!.removeAt(0);
          _relativeIndex = 1; // Our new relative index (it shifted down)
        } else {
          // We had no previous song, so now the song at 0 is our previous song
          _relativeIndex = 1;
        }

        // Preload the new next song if available
        final nextPreloadIndex = newIndex + 1;
        if (nextPreloadIndex < _playlist.length) {
          final preloadSource = await _createSource(_playlist[nextPreloadIndex]);
          await _currentPlaylistSource!.add(preloadSource);
        }
      } else {
        // Moved Backward
        final newIndex = _currentIndexInternal! - 1;
        if (newIndex < 0) return; // Start of playlist

        _setCurrentIndex(newIndex);

        // If we had a next song in the window, remove it.
        if (_currentPlaylistSource!.length > _relativeIndex + 1) {
          await _currentPlaylistSource!.removeAt(
            _currentPlaylistSource!.length - 1,
          );
        }

        // Preload the new previous song if available
        final prevPreloadIndex = newIndex - 1;
        if (prevPreloadIndex >= 0) {
          final preloadSource = await _createSource(_playlist[prevPreloadIndex]);
          await _currentPlaylistSource!.insert(0, preloadSource);
          _relativeIndex =
              1; // Because we inserted at 0, our current song shifted to 1
        } else {
          _relativeIndex = 0; // No previous song, so we are at index 0
        }
      }
    } finally {
      // UNLOCK the window — always unlock, even if an error occurs
      _isUpdatingWindow = false;
    }
  }

  // ============================================================
  // INTERNAL: SET CURRENT INDEX
  // ============================================================
  void _setCurrentIndex(int? index) {
    _currentIndexInternal = index;
    _currentIndexController.add(index);
  }

  // ============================================================
  // PLAY SONG (JIT LOAD)
  // ============================================================

  Future<void> playSongAt(int index) async {
    if (index < 0 || index >= _playlist.length) {
      return;
    }

    if (_currentIndexInternal == index) {
      if (_player.processingState == ProcessingState.completed) {
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
          final source = await _createSource(_playlist[index]);
          _relativeIndex = 0;
          await _player.setAudioSource(source);
        } else {
          _isUpdatingWindow = true;
          try {
            // Player is in completed state — seek+play alone won't work on mobile/web.
            // Build a FRESH source so just_audio re-emits duration properly.
            final freshSources = <AudioSource>[];
            int freshInitialIndex = 0;
            if (index - 1 >= 0) {
              freshSources.add(await _createSource(_playlist[index - 1]));
              freshInitialIndex = 1;
            }
            freshSources.add(await _createSource(_playlist[index]));
            if (index + 1 < _playlist.length) {
              freshSources.add(await _createSource(_playlist[index + 1]));
            }
            final freshSource = ConcatenatingAudioSource(children: freshSources);
            _relativeIndex = freshInitialIndex;
            await _player.setAudioSource(
              freshSource,
              initialIndex: freshInitialIndex,
              initialPosition: Duration.zero,
            );
            _currentPlaylistSource = freshSource;
          } finally {
            _isUpdatingWindow = false;
          }
        }
      } else {
        await _player.seek(Duration.zero);
      }
      await _player.play();
      return;
    }

    _currentPlaylistSource = null;
    _setCurrentIndex(index);

    // just_audio_media_kit (Windows) does NOT support ConcatenatingAudioSource.
    // Use a single AudioSource on Windows; use the sliding 3-song window elsewhere.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      final source = await _createSource(_playlist[index]);
      _relativeIndex = 0;
      await _player.setAudioSource(source);
    } else {
      _isUpdatingWindow = true;
      try {
        final sources = <AudioSource>[];
        int initialIndex = 0;

        // Previous
        if (index - 1 >= 0) {
          sources.add(await _createSource(_playlist[index - 1]));
          initialIndex = 1;
        }

        // Current
        sources.add(await _createSource(_playlist[index]));

        // Next
        if (index + 1 < _playlist.length) {
          sources.add(await _createSource(_playlist[index + 1]));
        }

        final newSource = ConcatenatingAudioSource(children: sources);
        await _player.stop();
        _relativeIndex = initialIndex;
        _currentPlaylistSource = newSource;

        await _player.setAudioSource(
          newSource,
          initialIndex: initialIndex,
          initialPosition: Duration.zero,
        );
      } finally {
        _isUpdatingWindow = false;
      }
    }

    await _player.play();
  }

  // ============================================================
  // PLAY / PAUSE
  // ============================================================

  Future<void> play() async {
    if (_playlist.isEmpty) return;
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  // ============================================================
  // NEXT
  // ============================================================

  Future<void> next() async {
    if (_playlist.isEmpty || _currentIndexInternal == null) return;

    final nextIndex = _currentIndexInternal! + 1;

    if (nextIndex < _playlist.length) {
      if (_player.hasNext) {
        await _player.seekToNext();
      } else {
        await playSongAt(nextIndex);
      }
    } else {
      await playSongAt(0);
    }
  }

  // ============================================================
  // PREVIOUS
  // ============================================================

  Future<void> previous() async {
    if (_playlist.isEmpty || _currentIndexInternal == null) return;

    final prevIndex = _currentIndexInternal! - 1;

    if (prevIndex >= 0) {
      if (_player.hasPrevious) {
        await _player.seekToPrevious();
      } else {
        await playSongAt(prevIndex);
      }
    } else {
      await playSongAt(_playlist.length - 1);
    }
  }

  // ============================================================
  // SEEK
  // ============================================================

  Future<void> seek(Duration position) async {
    final duration = _player.duration;

    if (duration == null) {
      await _player.seek(position);
      return;
    }

    var safePosition = position;
    if (safePosition < Duration.zero) safePosition = Duration.zero;
    if (safePosition > duration) safePosition = duration;

    await _player.seek(safePosition);
  }

  // ============================================================
  // VOLUME
  // ============================================================

  Future<void> setVolume(double volume) async {
    final safeVolume = volume.clamp(0.0, 1.0).toDouble();
    await _player.setVolume(safeVolume);
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  Future<void> dispose() async {
    await _justAudioIndexSub?.cancel();
    await _currentIndexController.close();
    await _player.dispose();
  }
}
