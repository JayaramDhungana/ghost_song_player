import 'package:just_audio/just_audio.dart';

import '../models/song.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  List<Song> _playlist = [];

  // ============================================================
  // STREAMS
  // ============================================================

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<Duration?> get durationStream => _player.durationStream;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  // ============================================================
  // PLAYER INFO
  // ============================================================

  bool get isPlaying => _player.playing;

  bool get isLoading =>
      _player.processingState == ProcessingState.loading ||
      _player.processingState == ProcessingState.buffering;

  int? get currentIndex => _player.currentIndex;

  Duration get position => _player.position;

  Duration? get duration => _player.duration;

  ProcessingState get processingState => _player.processingState;

  List<Song> get playlist => List.unmodifiable(_playlist);

  // ============================================================
  // CURRENT SONG
  // ============================================================

  Song? get currentSong {
    final index = _player.currentIndex;

    if (index == null ||
        index < 0 ||
        index >= _playlist.length) {
      return null;
    }

    return _playlist[index];
  }

  // ============================================================
  // SET PLAYLIST
  // ============================================================

  Future<void> setPlaylist(List<Song> songs) async {
    _playlist = List.unmodifiable(songs);

    if (_playlist.isEmpty) {
      await _player.stop();
      return;
    }

    final sources = <AudioSource>[];

    for (final song in _playlist) {
      final audioUrl = song.audioUrl;

      // --------------------------------------------------------
      // Local Flutter asset
      // --------------------------------------------------------

      if (audioUrl.startsWith('asset://')) {
        final assetPath =
            audioUrl.replaceFirst('asset://', '');

        sources.add(
          AudioSource.asset(
            assetPath,
            tag: song.id,
          ),
        );

        continue;
      }

      // --------------------------------------------------------
      // Remote URL
      // --------------------------------------------------------

      if (audioUrl.startsWith('http://') ||
          audioUrl.startsWith('https://')) {
        sources.add(
          AudioSource.uri(
            Uri.parse(audioUrl),
            tag: song.id,
          ),
        );

        continue;
      }

      throw ArgumentError(
        'Unsupported audio source: $audioUrl',
      );
    }

    // Stop previous playback before replacing playlist.
    await _player.stop();

    // Load playlist.
    //
    // Don't call play() here.
    await _player.setAudioSources(
      sources,
      initialIndex: 0,
      initialPosition: Duration.zero,
     
    );
  }

  // ============================================================
  // PLAY SONG
  // ============================================================

  Future<void> playSongAt(int index) async {
    if (index < 0 || index >= _playlist.length) {
      return;
    }

    // If the same song is selected again,
    // restart it from the beginning.
    if (_player.currentIndex == index) {
      await _player.seek(Duration.zero);
    } else {
      await _player.seek(
        Duration.zero,
        index: index,
      );
    }

    await _player.play();
  }

  // ============================================================
  // PLAY / PAUSE
  // ============================================================

  Future<void> play() async {
    if (_playlist.isEmpty) {
      return;
    }

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
    if (_playlist.isEmpty) {
      return;
    }

    if (_player.hasNext) {
      await _player.seekToNext();
    } else {
      await _player.seek(
        Duration.zero,
        index: 0,
      );
    }

    await _player.play();
  }

  // ============================================================
  // PREVIOUS
  // ============================================================

  Future<void> previous() async {
    if (_playlist.isEmpty) {
      return;
    }

    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else {
      await _player.seek(
        Duration.zero,
        index: _playlist.length - 1,
      );
    }

    await _player.play();
  }

  // ============================================================
  // SEEK
  // ============================================================

  Future<void> seek(Duration position) async {
    final duration = _player.duration;

    // If duration isn't known yet, let just_audio handle
    // the seek rather than blocking it from the Bloc.
    if (duration == null) {
      await _player.seek(position);
      return;
    }

    var safePosition = position;

    if (safePosition < Duration.zero) {
      safePosition = Duration.zero;
    }

    if (safePosition > duration) {
      safePosition = duration;
    }

    await _player.seek(safePosition);
  }

  // ============================================================
  // VOLUME
  // ============================================================

  Future<void> setVolume(double volume) async {
    final safeVolume =
        volume.clamp(0.0, 1.0).toDouble();

    await _player.setVolume(safeVolume);
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  Future<void> dispose() async {
    await _player.dispose();
  }
}