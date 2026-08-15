import 'package:just_audio/just_audio.dart';

import '../models/song.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  List<Song> _playlist = [];

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<Duration?> get durationStream => _player.durationStream;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  bool get isPlaying => _player.playing;

  int? get currentIndex => _player.currentIndex;

  Future<void> setPlaylist(List<Song> songs) async {
    _playlist = List.unmodifiable(songs);

    if (_playlist.isEmpty) {
      await _player.stop();
      return;
    }

    final sources = _playlist.map((song) {
      final audioUrl = song.audioUrl;

      // Local Flutter asset
      if (audioUrl.startsWith('asset://')) {
        final assetPath = audioUrl.replaceFirst('asset://', '');

        return AudioSource.asset(assetPath, tag: song.id);
      }

      // Remote audio (Cloudinary, etc.)
      if (audioUrl.startsWith('http://') || audioUrl.startsWith('https://')) {
        return AudioSource.uri(Uri.parse(audioUrl), tag: song.id);
      }

      throw ArgumentError('Unsupported audio source: $audioUrl');
    }).toList();

    await _player.setAudioSources(
      sources,
      initialIndex: 0,
      initialPosition: Duration.zero,
    );
  }

  Future<void> playSongAt(int index) async {
    if (index < 0 || index >= _playlist.length) {
      return;
    }

    await _player.seek(Duration.zero, index: index);

    await _player.play();
  }

  Future<void> next() async {
    if (_playlist.isEmpty) {
      return;
    }

    if (_player.hasNext) {
      await _player.seekToNext();
      await _player.play();
    } else {
      await _player.seek(Duration.zero, index: 0);
      await _player.play();
    }
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) {
      return;
    }

    if (_player.hasPrevious) {
      await _player.seekToPrevious();
      await _player.play();
    } else {
      await _player.seek(Duration.zero, index: _playlist.length - 1);
      await _player.play();
    }
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
