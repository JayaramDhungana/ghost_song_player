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
  StreamSubscription<int?>? _currentIndexSubscription;

  PlayerBloc({required AudioService audioService})
    : _audioService = audioService,
      super(const PlayerState()) {
    // User events
    on<LoadPlaylist>(_onLoadPlaylist);
    on<PlaySong>(_onPlaySong);
    on<TogglePlayPause>(_onTogglePlayPause);
    on<PauseSong>(_onPauseSong);
    on<NextSong>(_onNextSong);
    on<PreviousSong>(_onPreviousSong);
    on<SeekSong>(_onSeekSong);
    on<SetVolume>(_onSetVolume);

    // Audio player events
    on<PlayerPositionChanged>(_onPlayerPositionChanged);
    on<PlayerDurationChanged>(_onPlayerDurationChanged);
    on<AudioPlayerStateChanged>(_onAudioPlayerStateChanged);
    on<CurrentIndexChanged>(_onCurrentIndexChanged);

    _listenToAudioPlayer();
  }

  // ============================================================
  // JUST AUDIO STREAMS
  // ============================================================

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

    // IMPORTANT:
    // Only listen to index changes.
    //
    // We do NOT reset position/duration here.
    _currentIndexSubscription = _audioService.currentIndexStream.listen((
      index,
    ) {
      add(CurrentIndexChanged(index));
    });
  }

  // ============================================================
  // LOAD PLAYLIST
  // ============================================================

  Future<void> _onLoadPlaylist(
    LoadPlaylist event,
    Emitter<PlayerState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          playlist: event.songs,
          status: event.songs.isEmpty
              ? PlayerStatus.initial
              : PlayerStatus.loading,
          clearCurrentSong: true,
          clearError: true,
        ),
      );

      if (event.songs.isEmpty) {
        return;
      }

      await _audioService.setPlaylist(event.songs);

      emit(state.copyWith(status: PlayerStatus.ready));
    } catch (error) {
      emit(
        state.copyWith(
          status: PlayerStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // ============================================================
  // PLAY SONG
  // ============================================================

  Future<void> _onPlaySong(PlaySong event, Emitter<PlayerState> emit) async {
    try {
      final index = state.playlist.indexWhere(
        (song) => song.id == event.song.id,
      );

      if (index == -1) {
        return;
      }

      // Same song is already selected.
      // Don't reset duration — otherwise slider becomes inactive.
      if (_audioService.currentIndex == index) {
        await _audioService.seek(Duration.zero);
        await _audioService.play();

        return;
      }

      // Different song selected.
      emit(
        state.copyWith(
          status: PlayerStatus.loading,
          currentSong: event.song,
          position: Duration.zero,
          duration: Duration.zero,
          clearError: true,
        ),
      );

      await _audioService.playSongAt(index);
    } catch (error) {
      emit(
        state.copyWith(
          status: PlayerStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // ============================================================
  // TOGGLE PLAY / PAUSE
  // ============================================================

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

  // ============================================================
  // PAUSE
  // ============================================================

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

  // ============================================================
  // NEXT
  // ============================================================

  Future<void> _onNextSong(NextSong event, Emitter<PlayerState> emit) async {
    if (state.playlist.isEmpty) {
      return;
    }

    try {
      emit(state.copyWith(status: PlayerStatus.loading, clearError: true));

      await _audioService.next();

      // DO NOT manually update currentSong here.
      //
      // currentIndexStream will emit the new index.
      // _onCurrentIndexChanged() will update currentSong.
    } catch (error) {
      emit(
        state.copyWith(
          status: PlayerStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // ============================================================
  // PREVIOUS
  // ============================================================

  Future<void> _onPreviousSong(
    PreviousSong event,
    Emitter<PlayerState> emit,
  ) async {
    if (state.playlist.isEmpty) {
      return;
    }

    try {
      emit(state.copyWith(status: PlayerStatus.loading, clearError: true));

      await _audioService.previous();

      // currentIndexStream handles currentSong.
    } catch (error) {
      emit(
        state.copyWith(
          status: PlayerStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // ============================================================
  // SEEK
  // ============================================================

  Future<void> _onSeekSong(SeekSong event, Emitter<PlayerState> emit) async {
    try {
      await _audioService.seek(event.position);

      // positionStream is the source of truth.
      // Don't manually update state here.
    } catch (error) {
      emit(
        state.copyWith(
          status: PlayerStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // ============================================================
  // VOLUME
  // ============================================================

  Future<void> _onSetVolume(SetVolume event, Emitter<PlayerState> emit) async {
    try {
      final volume = event.volume.clamp(0.0, 1.0).toDouble();

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

  // ============================================================
  // POSITION CHANGED
  // ============================================================

  void _onPlayerPositionChanged(
    PlayerPositionChanged event,
    Emitter<PlayerState> emit,
  ) {
    emit(state.copyWith(position: event.position));
  }

  // ============================================================
  // DURATION CHANGED
  // ============================================================

  void _onPlayerDurationChanged(
    PlayerDurationChanged event,
    Emitter<PlayerState> emit,
  ) {
    emit(state.copyWith(duration: event.duration));
  }

  // ============================================================
  // CURRENT INDEX CHANGED
  // ============================================================

  void _onCurrentIndexChanged(
    CurrentIndexChanged event,
    Emitter<PlayerState> emit,
  ) {
    final index = event.index;

    if (index == null) {
      return;
    }

    if (index < 0 || index >= state.playlist.length) {
      return;
    }

    final song = state.playlist[index];

    // IMPORTANT:
    //
    // Only update currentSong.
    //
    // DO NOT reset:
    //   position
    //   duration
    //
    // This keeps the existing working slider/duration
    // behaviour untouched.
    emit(state.copyWith(currentSong: song, clearError: true));
  }

  // ============================================================
  // PLAYER STATE CHANGED
  // ============================================================

  void _onAudioPlayerStateChanged(
    AudioPlayerStateChanged event,
    Emitter<PlayerState> emit,
  ) {
    // Song completed.
    if (event.processingState == just_audio.ProcessingState.completed) {
      add(const NextSong());
      return;
    }

    final newStatus = event.isPlaying
        ? PlayerStatus.playing
        : PlayerStatus.paused;

    // Avoid unnecessary rebuilds.
    if (state.status == newStatus) {
      return;
    }

    emit(state.copyWith(status: newStatus));
  }

  // ============================================================
  // CLOSE
  // ============================================================

  @override
  Future<void> close() async {
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await _currentIndexSubscription?.cancel();

    await _audioService.dispose();

    return super.close();
  }
}
