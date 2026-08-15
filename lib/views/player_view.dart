import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/library/library_bloc.dart';
import '../../blocs/library/library_event.dart';
import '../../blocs/player/player_bloc.dart';
import '../../blocs/player/player_event.dart';
import '../../blocs/player/player_state.dart';
import '../../data/music_library.dart';
import '../../models/playlist.dart';
import '../../models/song.dart';
import '../../widgets/library/music_library.dart';
import '../../widgets/player/now_playing.dart';
import '../../widgets/player/secret_ui_toggle.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({super.key});

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  late final Playlist playlist;

  final ValueNotifier<bool> _isUiVisible = ValueNotifier(false);

  // Mobile full player state
  bool _isMobilePlayerExpanded = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerBloc>().add(LoadPlaylist(MusicLibraryData.songs));
    });
  }

  @override
  void dispose() {
    _isUiVisible.dispose();
    super.dispose();
  }

  void _openMobilePlayer() {
    setState(() {
      _isMobilePlayerExpanded = true;
    });
  }

  void _closeMobilePlayer() {
    setState(() {
      _isMobilePlayerExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          LibraryBloc(songs: MusicLibraryData.songs)..add(const LoadLibrary()),

      child: SecretUiToggle(
        visibility: _isUiVisible,

        child: Scaffold(
          body: ValueListenableBuilder<bool>(
            valueListenable: _isUiVisible,

            builder: (context, isVisible, child) {
              if (!isVisible) {
                return const SizedBox.expand();
              }

              return SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

                    return BlocBuilder<PlayerBloc, PlayerState>(
                      builder: (context, state) {
                        final currentSong = state.currentSong;

                        // ═════════════════════════════════════
                        // MOBILE
                        // ═════════════════════════════════════

                        if (isMobile) {
                          // Full-screen mobile player
                          if (_isMobilePlayerExpanded && currentSong != null) {
                            return _MobileFullPlayer(
                              song: currentSong,
                              state: state,
                              onClose: _closeMobilePlayer,
                            );
                          }

                          // Normal mobile library + mini player
                          return Column(
                            children: [
                              const SizedBox(height: 20),

                              const Text(
                                'Nepali Songs',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 12),

                              const Expanded(child: MusicLibrary()),

                              if (currentSong != null)
                                _MobileMiniPlayer(
                                  song: currentSong,
                                  state: state,
                                  onTap: _openMobilePlayer,
                                ),
                            ],
                          );
                        }

                        // ═════════════════════════════════════
                        // DESKTOP
                        // ═════════════════════════════════════

                        return Center(
                          child: SizedBox(
                            width: 600,
                            child: Column(
                              children: [
                                const SizedBox(height: 60),

                                const Text(
                                  'Nepali Songs',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                const Expanded(child: MusicLibrary()),

                                if (currentSong != null)
                                  NowPlaying(song: currentSong, state: state),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// MOBILE MINI PLAYER
// ═══════════════════════════════════════════════

class _MobileMiniPlayer extends StatelessWidget {
  final Song song;
  final PlayerState state;
  final VoidCallback onTap;

  const _MobileMiniPlayer({
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
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 4,
                  ),
                ),

                child: Slider(
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
                children: [
                  // Song info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          song.artist ?? 'Unknown Artist',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    tooltip: 'Previous',
                    icon: const Icon(Icons.skip_previous),
                    onPressed: state.status == PlayerStatus.loading
                        ? null
                        : () {
                            context.read<PlayerBloc>().add(
                              const PreviousSong(),
                            );
                          },
                  ),

                  IconButton(
                    tooltip: 'Play / Pause',
                    iconSize: 38,
                    onPressed: state.status == PlayerStatus.loading
                        ? null
                        : () {
                            context.read<PlayerBloc>().add(
                              const TogglePlayPause(),
                            );
                          },
                    icon: state.status == PlayerStatus.loading
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            state.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                          ),
                  ),

                  IconButton(
                    tooltip: 'Next',
                    icon: const Icon(Icons.skip_next),
                    onPressed: state.status == PlayerStatus.loading
                        ? null
                        : () {
                            context.read<PlayerBloc>().add(const NextSong());
                          },
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(state.position),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),

                  const Text(
                    'Tap for full player',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),

                  Text(
                    _formatDuration(state.duration),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
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
// MOBILE FULL PLAYER
// ═══════════════════════════════════════════════

class _MobileFullPlayer extends StatefulWidget {
  final Song song;
  final PlayerState state;
  final VoidCallback onClose;

  const _MobileFullPlayer({
    required this.song,
    required this.state,
    required this.onClose,
  });

  @override
  State<_MobileFullPlayer> createState() => _MobileFullPlayerState();
}

class _MobileFullPlayerState extends State<_MobileFullPlayer> {
  double _dragDistance = 0;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    // Only care about downward movement.
    if (details.delta.dy > 0) {
      _dragDistance += details.delta.dy;
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_dragDistance > 100) {
      widget.onClose();
    }

    _dragDistance = 0;
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.song;
    final state = widget.state;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onVerticalDragUpdate: _handleVerticalDragUpdate,

      onVerticalDragEnd: _handleVerticalDragEnd,

      child: Container(
        width: double.infinity,
        height: double.infinity,

        padding: const EdgeInsets.symmetric(horizontal: 24),

        child: Column(
          children: [
            // ─────────────────────────────
            // Top bar
            // ─────────────────────────────
            const SizedBox(height: 8),

            Row(
              children: [
                IconButton(
                  tooltip: 'Minimize',
                  icon: const Icon(Icons.keyboard_arrow_down, size: 32),
                  onPressed: widget.onClose,
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
              width: 190,
              height: 190,

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
                size: 90,
                color: Color(0xFFE8C98B),
              ),
            ),

            const SizedBox(height: 32),

            // ─────────────────────────────
            // Song title
            // ─────────────────────────────
            Text(
              song.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,

              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              song.artist ?? 'Unknown Artist',
              textAlign: TextAlign.center,

              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),

            const SizedBox(height: 32),

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
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  Text(
                    _formatDuration(state.duration),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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

                  onPressed: state.status == PlayerStatus.loading
                      ? null
                      : () {
                          context.read<PlayerBloc>().add(const PreviousSong());
                        },

                  icon: const Icon(Icons.skip_previous_rounded),
                ),

                const SizedBox(width: 20),

                IconButton(
                  iconSize: 70,

                  onPressed: state.status == PlayerStatus.loading
                      ? null
                      : () {
                          context.read<PlayerBloc>().add(
                            const TogglePlayPause(),
                          );
                        },

                  icon: state.status == PlayerStatus.loading
                      ? const SizedBox(
                          width: 55,
                          height: 55,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : Icon(
                          state.isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_filled_rounded,
                        ),
                ),

                const SizedBox(width: 20),

                IconButton(
                  iconSize: 40,

                  onPressed: state.status == PlayerStatus.loading
                      ? null
                      : () {
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

            const SizedBox(height: 12),

            const Text(
              'Swipe down to minimize',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
