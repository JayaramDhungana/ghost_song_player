import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/player/player_bloc.dart';
import '../../blocs/player/player_event.dart';
import '../../blocs/player/player_state.dart';
import '../../models/song.dart';

// ═══════════════════════════════════════════════
// MOBILE MINI PLAYER
// ═══════════════════════════════════════════════

class MiniPlayer extends StatelessWidget {
  final Song song;
  final PlayerState state;
  final VoidCallback onTap;

  const MiniPlayer({
    super.key,
    required this.song,
    required this.state,
    required this.onTap,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.97),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 18,
                offset: Offset(0, -4),
                color: Colors.black26,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  inactiveTrackColor: Colors.grey.withValues(alpha: 0.35),
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 4,
                  ),
                ),
                child: Slider(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  min: 0,
                  max: state.duration.inMilliseconds > 0
                      ? state.duration.inMilliseconds.toDouble()
                      : 1,
                  value: state.position.inMilliseconds
                      .clamp(
                        0,
                        state.duration.inMilliseconds > 0
                            ? state.duration.inMilliseconds
                            : 1,
                      )
                      .toDouble(),
                  onChanged: state.duration == Duration.zero
                      ? null
                      : (value) {
                          context.read<PlayerBloc>().add(
                            SeekSong(Duration(milliseconds: value.toInt())),
                          );
                        },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(state.position),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  Text(
                    _formatDuration(state.duration),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: 'Previous',
                    icon: const Icon(Icons.skip_previous),
                    onPressed: () {
                      context.read<PlayerBloc>().add(const PreviousSong());
                    },
                  ),
                  IconButton(
                    tooltip: 'Play / Pause',
                    iconSize: 38,
                    onPressed: () {
                      context.read<PlayerBloc>().add(const TogglePlayPause());
                    },
                    icon: Icon(
                      state.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next',
                    icon: const Icon(Icons.skip_next),
                    onPressed: () {
                      context.read<PlayerBloc>().add(const NextSong());
                    },
                  ),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tap for full player',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// Desktop Mini Player
// ═══════════════════════════════════════════════

class DesktopMiniPlayer extends StatelessWidget {
  final Song song;
  final PlayerState state;
  final VoidCallback onTap;

  const DesktopMiniPlayer({
    super.key,
    required this.song,
    required this.state,
    required this.onTap,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final durationMs = state.duration.inMilliseconds;
    final maxDuration = durationMs > 0 ? durationMs : 1;

    final position = state.position.inMilliseconds
        .clamp(0, maxDuration)
        .toDouble();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.97),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 18,
                offset: Offset(0, -4),
                color: Colors.black26,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ============================================================
              // PROGRESS
              // ============================================================
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  inactiveTrackColor: Colors.grey.withValues(alpha: 0.35),
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 4,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 10,
                  ),
                ),
                child: Slider(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  min: 0,
                  max: maxDuration.toDouble(),
                  value: position,
                  onChanged: state.duration == Duration.zero
                      ? null
                      : (value) {
                          context.read<PlayerBloc>().add(
                            SeekSong(Duration(milliseconds: value.toInt())),
                          );
                        },
                ),
              ),

              // ============================================================
              // CURRENT TIME / TOTAL TIME
              // ============================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(state.position),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  Text(
                    _formatDuration(state.duration),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),

              // ============================================================
              // SONG TITLE
              // ============================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              // ============================================================
              // CONTROLS
              //
              // LEFT   = Volume Down + Slider + Volume Up
              // CENTER = Previous + Play/Pause + Next
              // RIGHT  = Full Player
              // ============================================================
              SizedBox(
                height: 52,
                child: Row(
                  children: [
                    // ------------------------------------------------------
                    // LEFT: VOLUME
                    // ------------------------------------------------------
                    SizedBox(
                      width: 155,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.volume_down_rounded,
                            size: 17,
                            color: Colors.grey,
                          ),

                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                inactiveTrackColor: Colors.grey.withValues(
                                  alpha: 0.35,
                                ),
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 3,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 8,
                                ),
                              ),
                              child: Slider(
                                min: 0,
                                max: 1,
                                value: state.volume.clamp(0.0, 1.0),
                                onChanged: (value) {
                                  context.read<PlayerBloc>().add(
                                    SetVolume(value),
                                  );
                                },
                              ),
                            ),
                          ),

                          const Icon(
                            Icons.volume_up_rounded,
                            size: 21,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),

                    // ------------------------------------------------------
                    // CENTER: PLAYBACK BUTTONS
                    // ------------------------------------------------------
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            tooltip: 'Previous',
                            icon: const Icon(Icons.skip_previous),
                            onPressed: () {
                              context.read<PlayerBloc>().add(
                                const PreviousSong(),
                              );
                            },
                          ),

                          IconButton(
                            tooltip: 'Play / Pause',
                            iconSize: 38,
                            onPressed: () {
                              context.read<PlayerBloc>().add(
                                const TogglePlayPause(),
                              );
                            },
                            icon: Icon(
                              state.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                            ),
                          ),

                          IconButton(
                            tooltip: 'Next',
                            icon: const Icon(Icons.skip_next),
                            onPressed: () {
                              context.read<PlayerBloc>().add(const NextSong());
                            },
                          ),
                        ],
                      ),
                    ),

                    // ------------------------------------------------------
                    // RIGHT: FULL PLAYER
                    // ------------------------------------------------------
                    SizedBox(
                      width: 155,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          tooltip: 'Open full player',
                          icon: const Icon(Icons.open_in_full, size: 18),
                          onPressed: onTap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// MOBILE FULL PLAYER (MODAL SHEET)
// ═══════════════════════════════════════════════

class MobileFullPlayer extends StatelessWidget {
  final Song song;
  final PlayerState state;

  const MobileFullPlayer({super.key, required this.song, required this.state});

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        final currentSong = state.currentSong ?? song;

        return Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Column(
                children: [
                  // ─────────────────────────────
                  // Top bar
                  // ─────────────────────────────
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Minimize',
                        icon: const Icon(Icons.keyboard_arrow_down, size: 32),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'NOW PLAYING',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),

                  const Spacer(),

                  // ─────────────────────────────
                  // Music icon
                  // ─────────────────────────────
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF24243E),
                          Color(0xFF302B63),
                          Color(0xFF0F0C29),
                        ],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 35,
                          spreadRadius: 2,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.music_note_rounded,
                      size: 110,
                      color: Color(0xFFE8C98B),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ─────────────────────────────
                  // Song title
                  // ─────────────────────────────
                  Text(
                    currentSong.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentSong.artist ?? 'Unknown Artist',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),

                  const SizedBox(height: 40),

                  // ─────────────────────────────
                  // Progress
                  // ─────────────────────────────
                  Slider(
                    min: 0,
                    max: state.duration.inMilliseconds > 0
                        ? state.duration.inMilliseconds.toDouble()
                        : 1,
                    value: state.position.inMilliseconds
                        .clamp(
                          0,
                          state.duration.inMilliseconds > 0
                              ? state.duration.inMilliseconds
                              : 1,
                        )
                        .toDouble(),
                    onChanged: state.duration == Duration.zero
                        ? null
                        : (value) {
                            context.read<PlayerBloc>().add(
                              SeekSong(Duration(milliseconds: value.toInt())),
                            );
                          },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(state.position),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _formatDuration(state.duration),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─────────────────────────────
                  // Controls
                  // ─────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 40,
                        onPressed: () {
                          context.read<PlayerBloc>().add(const PreviousSong());
                        },
                        icon: const Icon(Icons.skip_previous_rounded),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        iconSize: 70,
                        onPressed: () {
                          context.read<PlayerBloc>().add(
                            const TogglePlayPause(),
                          );
                        },
                        icon: Icon(
                          state.isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_filled_rounded,
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        iconSize: 40,
                        onPressed: () {
                          context.read<PlayerBloc>().add(const NextSong());
                        },
                        icon: const Icon(Icons.skip_next_rounded),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ─────────────────────────────
                  // Volume
                  // ─────────────────────────────
                  Row(
                    children: [
                      const Icon(Icons.volume_down, size: 20),
                      Expanded(
                        child: Slider(
                          value: state.volume,
                          min: 0,
                          max: 1,
                          onChanged: (value) {
                            context.read<PlayerBloc>().add(SetVolume(value));
                          },
                        ),
                      ),
                      const Icon(Icons.volume_up, size: 20),
                    ],
                  ),

                  const Spacer(),
                ],
              ),
            ),
            const SongLoadingToast(),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════
// SONG LOADING TOAST
// ═══════════════════════════════════════════════

/// A beautiful centered toast overlay that appears when a song is loading.
/// Shows the song title with a spinner animation.
class SongLoadingToast extends StatelessWidget {
  const SongLoadingToast({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      buildWhen: (prev, curr) =>
          prev.status != curr.status || prev.currentSong != curr.currentSong,
      builder: (context, state) {
        final isLoading = state.status == PlayerStatus.loading;
        final song = state.currentSong;

        return IgnorePointer(
          ignoring: !isLoading,
          child: AnimatedOpacity(
            opacity: isLoading && song != null ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 20,
                      spreadRadius: 2,
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 14),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Playing song...',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song?.title ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
