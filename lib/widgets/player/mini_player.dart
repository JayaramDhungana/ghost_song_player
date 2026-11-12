import 'dart:math' as math;
import 'dart:ui';
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
    final progress = (state.duration.inMilliseconds > 0)
        ? (state.position.inMilliseconds / state.duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF161622).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 20,
                  offset: Offset(0, 8),
                  color: Colors.black54,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top sleek 2.5px progress indicator
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 2.5,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA855F7)),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          // Mini Vinyl Album Art
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFA855F7).withValues(alpha: 0.35),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.25),
                                    ),
                                  ),
                                ),
                                Icon(
                                  state.isPlaying
                                      ? Icons.music_note_rounded
                                      : Icons.pause_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  song.artist?.isNotEmpty == true
                                      ? song.artist!
                                      : 'Unknown Artist',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFA855F7),
                              foregroundColor: Colors.white,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(8),
                              minimumSize: const Size(36, 36),
                            ),
                            icon: Icon(
                              state.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 20,
                            ),
                            onPressed: () {
                              context.read<PlayerBloc>().add(const TogglePlayPause());
                            },
                          ),
                          const SizedBox(width: 2),
                          IconButton(
                            icon: const Icon(Icons.skip_next_rounded, size: 24),
                            color: Colors.white.withValues(alpha: 0.8),
                            onPressed: () {
                              context.read<PlayerBloc>().add(const NextSong());
                            },
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
    final durationMs = state.duration.inMilliseconds;
    final maxDuration = durationMs > 0 ? durationMs : 1;

    final position = state.position.inMilliseconds
        .clamp(0, maxDuration)
        .toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: BoxDecoration(
            color: const Color(0xFF161622).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 24,
                offset: const Offset(0, 8),
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ============================================================
              // 3-SECTION HORIZONTAL ROW
              // Left: Info | Center: Controls | Right: Tools
              // ============================================================
              Row(
                children: [
                  // ─────────────────────────────────────────
                  // LEFT: Track Info + Album Art
                  // ─────────────────────────────────────────
                  Expanded(
                    flex: 3,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: onTap,
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFA855F7).withValues(alpha: 0.35),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.25),
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    state.isPlaying
                                        ? Icons.music_note_rounded
                                        : Icons.pause_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    song.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    song.artist?.isNotEmpty == true
                                        ? song.artist!
                                        : 'Unknown Artist',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: Colors.grey.shade400,
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

                  // ─────────────────────────────────────────
                  // CENTER: Playback Buttons
                  // ─────────────────────────────────────────
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          tooltip: 'Previous',
                          iconSize: 22,
                          icon: const Icon(Icons.skip_previous_rounded),
                          color: Colors.white.withValues(alpha: 0.8),
                          onPressed: () {
                            context.read<PlayerBloc>().add(const PreviousSong());
                          },
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          tooltip: 'Play / Pause',
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFA855F7),
                            foregroundColor: Colors.white,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(9),
                            shadowColor: const Color(0xFFA855F7).withValues(alpha: 0.5),
                            elevation: 6,
                          ),
                          icon: Icon(
                            state.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 22,
                          ),
                          onPressed: () {
                            context.read<PlayerBloc>().add(const TogglePlayPause());
                          },
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          tooltip: 'Next',
                          iconSize: 22,
                          icon: const Icon(Icons.skip_next_rounded),
                          color: Colors.white.withValues(alpha: 0.8),
                          onPressed: () {
                            context.read<PlayerBloc>().add(const NextSong());
                          },
                        ),
                      ],
                    ),
                  ),

                  // ─────────────────────────────────────────
                  // RIGHT: Volume + Fullscreen Expand
                  // ─────────────────────────────────────────
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(
                          Icons.volume_down_rounded,
                          size: 16,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 68,
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFFA855F7),
                              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
                            ),
                            child: Slider(
                              min: 0,
                              max: 1,
                              value: state.volume.clamp(0.0, 1.0),
                              onChanged: (val) {
                                context.read<PlayerBloc>().add(SetVolume(val));
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          tooltip: 'Open full player',
                          icon: const Icon(Icons.open_in_full_rounded, size: 16),
                          color: Colors.white.withValues(alpha: 0.8),
                          onPressed: onTap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // ============================================================
              // PROGRESS BAR + TIMESTAMPS
              // ============================================================
              Row(
                children: [
                  Text(
                    _formatDuration(state.position),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFFA855F7),
                        inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
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
                  ),
                  const SizedBox(width: 8),
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
    const activeColor = Color(0xFFA855F7);

    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        final currentSong = state.currentSong ?? song;

        final durationMs = state.duration.inMilliseconds;
        final maxDuration = durationMs > 0 ? durationMs : 1;
        final position = state.position.inMilliseconds
            .clamp(0, maxDuration)
            .toDouble();

        return Stack(
          children: [
            // Dynamic breathing background aurora
            _DynamicBackgroundAurora(isPlaying: state.isPlaying),

            // Main Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Top Bar (Minimize + NOW PLAYING)
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Minimize',
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 32,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'NOW PLAYING',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.5,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),

                    const Spacer(flex: 1),

                    // Center Futuristic Pulsing Sound Orb (Option 3)
                    _PulsingSoundOrb(isPlaying: state.isPlaying),

                    const Spacer(flex: 1),

                    // Song Title & Artist
                    Text(
                      currentSong.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentSong.artist?.isNotEmpty == true
                          ? currentSong.artist!
                          : 'Unknown Artist',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: Colors.purple.shade200,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 🚀 LIVE ENERGETIC AUDIO WAVE VISUALIZER
                    _LiveAudioWaveVisualizer(isPlaying: state.isPlaying),

                    const SizedBox(height: 16),

                    // Seek Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: activeColor,
                        inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
                        trackHeight: 3.5,
                        thumbColor: Colors.white,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
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

                    // Timestamps
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

                    // Playback Controls (Prev, Big Glow Play/Pause, Next)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 42,
                          color: Colors.white.withValues(alpha: 0.85),
                          onPressed: () {
                            context.read<PlayerBloc>().add(const PreviousSong());
                          },
                          icon: const Icon(Icons.skip_previous_rounded),
                        ),
                        const SizedBox(width: 24),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: activeColor.withValues(alpha: 0.45),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: activeColor,
                              foregroundColor: Colors.white,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(18),
                            ),
                            iconSize: 38,
                            onPressed: () {
                              context.read<PlayerBloc>().add(const TogglePlayPause());
                            },
                            icon: Icon(
                              state.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          iconSize: 42,
                          color: Colors.white.withValues(alpha: 0.85),
                          onPressed: () {
                            context.read<PlayerBloc>().add(const NextSong());
                          },
                          icon: const Icon(Icons.skip_next_rounded),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Volume Row
                    Row(
                      children: [
                        const Icon(Icons.volume_down_rounded, size: 20, color: Colors.grey),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: activeColor,
                              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                              trackHeight: 3,
                              thumbColor: Colors.white,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                            ),
                            child: Slider(
                              value: state.volume.clamp(0.0, 1.0),
                              min: 0,
                              max: 1,
                              onChanged: (value) {
                                context.read<PlayerBloc>().add(SetVolume(value));
                              },
                            ),
                          ),
                        ),
                        const Icon(Icons.volume_up_rounded, size: 20, color: Colors.grey),
                      ],
                    ),

                    const Spacer(flex: 1),
                  ],
                ),
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
// FUTURISTIC PULSING SOUND ORB (OPTION 3)
// ═══════════════════════════════════════════════

class _PulsingSoundOrb extends StatefulWidget {
  final bool isPlaying;

  const _PulsingSoundOrb({required this.isPlaying});

  @override
  State<_PulsingSoundOrb> createState() => _PulsingSoundOrbState();
}

class _PulsingSoundOrbState extends State<_PulsingSoundOrb>
    with TickerProviderStateMixin {
  late final AnimationController _waveController;
  late final AnimationController _beatController;
  late final AnimationController _swirlController;

  @override
  void initState() {
    super.initState();

    // 1. Concentric acoustic ripple rings
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    // 2. Energetic bass beat pulse
    _beatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 3. Fluid cosmic energy swirl
    _swirlController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    if (widget.isPlaying) {
      _waveController.repeat();
      _beatController.repeat(reverse: true);
      _swirlController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _PulsingSoundOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        if (!_waveController.isAnimating) _waveController.repeat();
        if (!_beatController.isAnimating) _beatController.repeat(reverse: true);
        if (!_swirlController.isAnimating) _swirlController.repeat();
      } else {
        _waveController.stop();
        _beatController.stop();
        _swirlController.stop();
      }
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _beatController.dispose();
    _swirlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const orbDiameter = 190.0;
    const canvasSize = 270.0;

    return SizedBox(
      width: canvasSize,
      height: canvasSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ─────────────────────────────────────────
          // 1. CONCENTRIC OUTWARD SOUND RIPPLES
          // ─────────────────────────────────────────
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, _) {
              return CustomPaint(
                size: const Size(canvasSize, canvasSize),
                painter: _SoundOrbWavePainter(
                  waveProgress: _waveController.value,
                  isPlaying: widget.isPlaying,
                ),
              );
            },
          ),

          // ─────────────────────────────────────────
          // 2. THE GLOWING 3D FUTURISTIC SOUND ORB
          // ─────────────────────────────────────────
          AnimatedBuilder(
            animation: _beatController,
            builder: (context, child) {
              final beat = widget.isPlaying ? _beatController.value : 0.0;
              final scale = 1.0 + (beat * 0.06);
              final blur = 32.0 + (beat * 24.0);
              final spread = 2.0 + (beat * 6.0);

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: orbDiameter,
                  height: orbDiameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      // Outer Royal Violet Halo
                      BoxShadow(
                        color: const Color(0xFFA855F7).withValues(alpha: widget.isPlaying ? 0.55 : 0.25),
                        blurRadius: blur,
                        spreadRadius: spread,
                      ),
                      // Cyber Cyan Ambient Underglow
                      BoxShadow(
                        color: const Color(0xFF06B6D4).withValues(alpha: widget.isPlaying ? 0.40 : 0.15),
                        blurRadius: blur * 0.75,
                        offset: const Offset(-4, -4),
                      ),
                      // Hot Pink Pulse Accent
                      BoxShadow(
                        color: const Color(0xFFEC4899).withValues(alpha: widget.isPlaying ? 0.35 : 0.10),
                        blurRadius: blur * 0.8,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: child,
                ),
              );
            },
            child: ClipOval(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Layer A: Swirling Liquid Energy Gradient
                  RotationTransition(
                    turns: _swirlController,
                    child: Container(
                      width: orbDiameter,
                      height: orbDiameter,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            Color(0xFF6366F1), // Electric Indigo
                            Color(0xFFA855F7), // Royal Violet
                            Color(0xFFEC4899), // Hot Pink
                            Color(0xFF06B6D4), // Cyber Cyan
                            Color(0xFF3B82F6), // Ocean Blue
                            Color(0xFF6366F1), // Loop
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Layer B: Subtle Dark Glass Core for Deep Contrast
                  Container(
                    width: orbDiameter,
                    height: orbDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFF0D0B18).withValues(alpha: 0.25),
                          const Color(0xFF090812).withValues(alpha: 0.65),
                        ],
                        stops: const [0.4, 0.8, 1.0],
                      ),
                    ),
                  ),

                  // Layer C: 3D Top Glass Specular Highlight (Apple Siri Sheen)
                  Positioned(
                    top: 10,
                    left: 28,
                    right: 28,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(orbDiameter, 60),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.45),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Layer D: Inner Frosted Glass Lens & Floating Music Icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0F0E1A).withValues(alpha: 0.42),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        widget.isPlaying
                            ? Icons.music_note_rounded
                            : Icons.headphones_rounded,
                        color: Colors.white,
                        size: 34,
                        shadows: [
                          Shadow(
                            color: const Color(0xFFA855F7).withValues(alpha: 0.8),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Layer E: Ultra-fine Outer Rim Border
                  Container(
                    width: orbDiameter,
                    height: orbDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter that renders concentric acoustic ripple waves expanding outward
class _SoundOrbWavePainter extends CustomPainter {
  final double waveProgress;
  final bool isPlaying;

  _SoundOrbWavePainter({
    required this.waveProgress,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isPlaying) return;

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.36;
    final maxRadius = size.width * 0.49;
    final radiusSpan = maxRadius - baseRadius;

    // 3 Staggered concentric ripple rings
    const ringCount = 3;
    for (int i = 0; i < ringCount; i++) {
      final ringProgress = (waveProgress + (i / ringCount)) % 1.0;
      final currentRadius = baseRadius + (radiusSpan * ringProgress);
      final opacity = (1.0 - ringProgress).clamp(0.0, 1.0) * 0.55;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * (1.0 - (ringProgress * 0.45))
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF06B6D4).withValues(alpha: opacity),
            const Color(0xFFA855F7).withValues(alpha: opacity * 0.9),
            const Color(0xFFEC4899).withValues(alpha: opacity * 0.6),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: currentRadius));

      canvas.drawCircle(center, currentRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SoundOrbWavePainter oldDelegate) {
    return oldDelegate.waveProgress != waveProgress ||
        oldDelegate.isPlaying != isPlaying;
  }
}

// ═══════════════════════════════════════════════
// LIVE ENERGETIC AUDIO WAVEFORM VISUALIZER
// ═══════════════════════════════════════════════

class _LiveAudioWaveVisualizer extends StatefulWidget {
  final bool isPlaying;

  const _LiveAudioWaveVisualizer({required this.isPlaying});

  @override
  State<_LiveAudioWaveVisualizer> createState() => _LiveAudioWaveVisualizerState();
}

class _LiveAudioWaveVisualizerState extends State<_LiveAudioWaveVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _LiveAudioWaveVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        if (!_controller.isAnimating) _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const int barCount = 28;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;

        return SizedBox(
          height: 38,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(barCount, (i) {
              double height;
              if (!widget.isPlaying) {
                height = 3.5;
              } else {
                // Harmonic multi-frequency audio bounce simulation
                final phase = (i / barCount) * math.pi * 2;
                final wave1 = math.sin((t * math.pi * 2) + phase);
                final wave2 = math.cos((t * math.pi * 4) + (phase * 1.5));
                final wave3 = math.sin((t * math.pi * 6) - (phase * 0.8));

                // Bell curve envelope: center frequencies jump higher
                final bell = math.sin((i / (barCount - 1)) * math.pi);
                final combined = ((wave1 * 0.5) + (wave2 * 0.3) + (wave3 * 0.2)).abs();

                height = 4.0 + (combined * 32.0 * bell);
              }

              // Color gradient across bars from Electric Indigo to Neon Pink
              final ratio = i / barCount;
              final barColor = Color.lerp(
                const Color(0xFF6366F1),
                const Color(0xFFA855F7),
                ratio,
              )!;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Container(
                  width: 3.2,
                  height: height.clamp(3.5, 36.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        barColor.withValues(alpha: 0.5),
                        barColor,
                      ],
                    ),
                    boxShadow: widget.isPlaying
                        ? [
                            BoxShadow(
                              color: barColor.withValues(alpha: 0.45),
                              blurRadius: 5,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════
// DYNAMIC BREATHING AURORA BACKGROUND
// ═══════════════════════════════════════════════

class _DynamicBackgroundAurora extends StatefulWidget {
  final bool isPlaying;

  const _DynamicBackgroundAurora({required this.isPlaying});

  @override
  State<_DynamicBackgroundAurora> createState() => _DynamicBackgroundAuroraState();
}

class _DynamicBackgroundAuroraState extends State<_DynamicBackgroundAurora>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    if (widget.isPlaying) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _DynamicBackgroundAurora oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        if (!_controller.isAnimating) _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final color1 = Color.lerp(
          const Color(0xFF6366F1),
          const Color(0xFFEC4899),
          t,
        )!;
        final color2 = Color.lerp(
          const Color(0xFFA855F7),
          const Color(0xFF06B6D4),
          t,
        )!;

        return Stack(
          children: [
            // Base luxury midnight dark
            Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF0D0D14),
            ),

            // Floating moving Orb 1 (top-left)
            Positioned(
              top: -60 + (30 * math.sin(t * math.pi)),
              left: -60 + (25 * math.cos(t * math.pi)),
              child: Container(
                width: 290,
                height: 290,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color1.withValues(alpha: widget.isPlaying ? 0.22 : 0.10),
                ),
              ),
            ),

            // Floating moving Orb 2 (bottom-right)
            Positioned(
              bottom: -40 - (25 * math.sin(t * math.pi)),
              right: -40 - (30 * math.cos(t * math.pi)),
              child: Container(
                width: 290,
                height: 290,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color2.withValues(alpha: widget.isPlaying ? 0.20 : 0.08),
                ),
              ),
            ),

            // Heavy frosted glass blur for ambient glow
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 65, sigmaY: 65),
              child: const SizedBox.expand(),
            ),
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
