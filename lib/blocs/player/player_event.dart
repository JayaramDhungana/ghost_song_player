import 'package:just_audio/just_audio.dart' as just_audio;

import '../../models/song.dart';

sealed class PlayerEvent {
  const PlayerEvent();
}

class LoadPlaylist extends PlayerEvent {
  final List<Song> songs;

  const LoadPlaylist(this.songs);
}

class PlaySong extends PlayerEvent {
  final Song song;

  const PlaySong(this.song);
}

class TogglePlayPause extends PlayerEvent {
  const TogglePlayPause();
}

class PauseSong extends PlayerEvent {
  const PauseSong();
}

class NextSong extends PlayerEvent {
  const NextSong();
}

class PreviousSong extends PlayerEvent {
  const PreviousSong();
}

class SeekSong extends PlayerEvent {
  final Duration position;

  const SeekSong(this.position);
}

class SetVolume extends PlayerEvent {
  final double volume;

  const SetVolume(this.volume);
}

class PlayerPositionChanged extends PlayerEvent {
  final Duration position;

  const PlayerPositionChanged(this.position);
}

class PlayerDurationChanged extends PlayerEvent {
  final Duration duration;

  const PlayerDurationChanged(this.duration);
}

class AudioPlayerStateChanged extends PlayerEvent {
  final bool isPlaying;
  final just_audio.ProcessingState processingState;

  const AudioPlayerStateChanged({
    required this.isPlaying,
    required this.processingState,
  });
}


class CurrentIndexChanged extends PlayerEvent {
  final int? index;

  const CurrentIndexChanged(this.index);

}

