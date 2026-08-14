import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' as just_audio;

import '../../services/audio_service.dart';
import 'player_event.dart';
import 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioService _audioService;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<just_audio.PlayerState>? _playerStateSubscription;

  PlayerBloc({required AudioService audioService})
    : _audioService = audioService,
      super(const PlayerState()) {
    on<LoadPlaylist>(_onLoadPlaylist);
    on<PlaySong>(_onPlaySong);
    on<TogglePlayPause>(_onTogglePlayPause);
    on<PauseSong>(_onPauseSong);
    on<NextSong>(_onNextSong);
    on<PreviousSong>(_onPreviousSong);
    on<SeekSong>(_onSeekSong);
    on<SetVolume>(_onSetVolume);

    on<PlayerPositionChanged>(_onPlayerPositionChanged);
    on<PlayerDurationChanged>(_onPlayerDurationChanged);
    on<AudioPlayerStateChanged>(_onAudioPlayerStateChanged);

    _listenToAudioPlayer();
  }

  void _listenToAudioPlayer() {
    _positionSubscription = _audioService.positionStream.listen((position) {
      add(PlayerPositionChanged(position));
    });

    _durationSubscription = _audioService.durationStream.listen((duration) {
      if (duration == null) return;

      add(PlayerDurationChanged(duration));
    });

    _playerStateSubscription = _audioService.playerStateStream.listen((
      playerState,
    ) {
      add(
        AudioPlayerStateChanged(
          isPlaying: playerState.playing,
          processingState: playerState.processingState,
        ),
      );
    });
  }

  Future<void> _onLoadPlaylist(
    LoadPlaylist event,
    Emitter<PlayerState> emit,
  ) async {
    emit(
      state.copyWith(
        playlist: event.songs,
        status: event.songs.isEmpty ? PlayerStatus.initial : PlayerStatus.ready,
        clearError: true,
      ),
    );
  }

  Future<void> _onPlaySong(PlaySong event, Emitter<PlayerState> emit) async {
    try {
      emit(
        state.copyWith(
          status: PlayerStatus.loading,
          currentSong: event.song,
          position: Duration.zero,
          duration: Duration.zero,
          clearError: true,
        ),
      );

      await _audioService.setSong(event.song);
      await _audioService.play();

      emit(state.copyWith(currentSong: event.song));
    } catch (error) {
      emit(
        state.copyWith(
          status: PlayerStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onTogglePlayPause(
    TogglePlayPause event,
    Emitter<PlayerState> emit,
  ) async {
    if (state.currentSong == null) {
      return;
    }

    try {
      if (_audioService.isPlaying) {
        await _audioService.pause();
      } else {
        await _audioService.play();
      }
    } catch (error) {
      emit(
        state.copyWith(
          status: PlayerStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onPauseSong(PauseSong event, Emitter<PlayerState> emit) async {
    try {
      await _audioService.pause();

      emit(state.copyWith(status: PlayerStatus.paused));
    } catch (error) {
      emit(
        state.copyWith(
          status: PlayerStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onNextSong(NextSong event, Emitter<PlayerState> emit) async {
    if (state.playlist.isEmpty) {
      return;
    }

    final currentIndex = state.currentSong == null
        ? -1
        : state.playlist.indexWhere((song) => song.id == state.currentSong!.id);

    final nextIndex = currentIndex < 0
        ? 0
        : (currentIndex + 1) % state.playlist.length;

    add(PlaySong(state.playlist[nextIndex]));
  }

  Future<void> _onPreviousSong(
    PreviousSong event,
    Emitter<PlayerState> emit,
  ) async {
    if (state.playlist.isEmpty) {
      return;
    }

    final currentIndex = state.currentSong == null
        ? 0
        : state.playlist.indexWhere((song) => song.id == state.currentSong!.id);

    final previousIndex = currentIndex <= 0
        ? state.playlist.length - 1
        : currentIndex - 1;

    add(PlaySong(state.playlist[previousIndex]));
  }

  Future<void> _onSeekSong(SeekSong event, Emitter<PlayerState> emit) async {
    try {
      await _audioService.seek(event.position);

      emit(state.copyWith(position: event.position));
    } catch (error) {
      emit(
        state.copyWith(
          status: PlayerStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onSetVolume(SetVolume event, Emitter<PlayerState> emit) async {
    try {
      final volume = event.volume.clamp(0.0, 1.0);

      await _audioService.setVolume(volume);

      emit(state.copyWith(volume: volume));
    } catch (error) {
      emit(
        state.copyWith(
          status: PlayerStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onPlayerPositionChanged(
    PlayerPositionChanged event,
    Emitter<PlayerState> emit,
  ) {
    emit(state.copyWith(position: event.position));
  }

  void _onPlayerDurationChanged(
    PlayerDurationChanged event,
    Emitter<PlayerState> emit,
  ) {
    emit(state.copyWith(duration: event.duration));
  }

  void _onAudioPlayerStateChanged(
    AudioPlayerStateChanged event,
    Emitter<PlayerState> emit,
  ) {
    if (event.processingState == just_audio.ProcessingState.completed) {
      add(const NextSong());
      return;
    }

    final newStatus = event.isPlaying
        ? PlayerStatus.playing
        : PlayerStatus.paused;

    if (state.status == newStatus) {
      return;
    }

    emit(state.copyWith(status: newStatus));
  }

  @override
  Future<void> close() async {
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _playerStateSubscription?.cancel();

    await _audioService.dispose();

    return super.close();
  }
}
