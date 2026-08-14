import '../../models/song.dart';

enum PlayerStatus {
  initial,
  loading,
  ready,
  playing,
  paused,
  error,
}

class PlayerState {
  final PlayerStatus status;
  final List<Song> playlist;
  final Song? currentSong;
  final Duration position;
  final Duration duration;
  final double volume;
  final String? errorMessage;

  const PlayerState({
    this.status = PlayerStatus.initial,
    this.playlist = const [],
    this.currentSong,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.errorMessage,
  });

  PlayerState copyWith({
    PlayerStatus? status,
    List<Song>? playlist,
    Song? currentSong,
    Duration? position,
    Duration? duration,
    double? volume,
    String? errorMessage,
    bool clearCurrentSong = false,
    bool clearError = false,
  }) {
    return PlayerState(
      status: status ?? this.status,
      playlist: playlist ?? this.playlist,
      currentSong: clearCurrentSong ? null : currentSong ?? this.currentSong,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  bool get isPlaying => status == PlayerStatus.playing;

  bool get hasPlaylist => playlist.isNotEmpty;

  bool get hasCurrentSong => currentSong != null;
}