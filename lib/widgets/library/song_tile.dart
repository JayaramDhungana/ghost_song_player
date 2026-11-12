import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/song.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final bool isCurrentSong;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onPlayPause;

  const SongTile({
    super.key,
    required this.song,
    required this.isCurrentSong,
    required this.isPlaying,
    required this.onTap,
    required this.onPlayPause,
  });

  // Signature active gradient (Royal Indigo to Purple Glow)
  static const List<Color> _activeGradient = [
    Color(0xFF6366F1), // Electric Indigo
    Color(0xFFA855F7), // Royal Violet
  ];

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFA855F7);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isCurrentSong
              ? activeColor.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.03),
          border: Border.all(
            color: isCurrentSong
                ? activeColor.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.06),
            width: isCurrentSong ? 1.4 : 1.0,
          ),
          boxShadow: isCurrentSong
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // ─────────────────────────────────────────
                  // Monochromatic Luxury Thumbnail
                  // ─────────────────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: isCurrentSong
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _activeGradient,
                            )
                          : null,
                      color: isCurrentSong
                          ? null
                          : Colors.white.withValues(alpha: 0.06),
                      border: Border.all(
                        color: isCurrentSong
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                      boxShadow: isCurrentSong
                          ? [
                              BoxShadow(
                                color: _activeGradient.first.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Concentric vinyl groove ring
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCurrentSong
                                  ? Colors.white.withValues(alpha: 0.3)
                                  : Colors.white.withValues(alpha: 0.08),
                              width: 1,
                            ),
                          ),
                        ),
                        if (isCurrentSong && isPlaying)
                          const _LiveEqualizerBars()
                        else if (isCurrentSong && !isPlaying)
                          const Icon(
                            Icons.pause_rounded,
                            color: Colors.white,
                            size: 24,
                          )
                        else
                          Icon(
                            Icons.music_note_rounded,
                            color: Colors.white.withValues(alpha: 0.65),
                            size: 22,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  // ─────────────────────────────────────────
                  // Song Details (Title + Clean Artist)
                  // ─────────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          song.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.5,
                            height: 1.25,
                            fontWeight: isCurrentSong
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isCurrentSong
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.92),
                            letterSpacing: 0.15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          song.artist?.isNotEmpty == true
                              ? song.artist!
                              : 'Unknown Artist',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isCurrentSong
                                ? Colors.purple.shade200
                                : Colors.grey.shade400,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ─────────────────────────────────────────
                  // Sleek Play / Pause Action Button
                  // ─────────────────────────────────────────
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: isCurrentSong
                          ? activeColor
                          : Colors.white.withValues(alpha: 0.06),
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(38, 38),
                    ),
                    icon: Icon(
                      isCurrentSong && isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 20,
                      color: isCurrentSong
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.75),
                    ),
                    onPressed: onPlayPause,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dynamic live equalizer wave animation (4 vertical dancing bars)
class _LiveEqualizerBars extends StatefulWidget {
  const _LiveEqualizerBars();

  @override
  State<_LiveEqualizerBars> createState() => _LiveEqualizerBarsState();
}

class _LiveEqualizerBarsState extends State<_LiveEqualizerBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
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
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBar(4 + (14 * math.sin(t * math.pi)).abs()),
            const SizedBox(width: 2.5),
            _buildBar(6 + (16 * math.cos(t * math.pi)).abs()),
            const SizedBox(width: 2.5),
            _buildBar(5 + (18 * math.sin((t + 0.5) * math.pi)).abs()),
            const SizedBox(width: 2.5),
            _buildBar(4 + (12 * math.cos((t + 0.3) * math.pi)).abs()),
          ],
        );
      },
    );
  }

  Widget _buildBar(double height) {
    return Container(
      width: 3,
      height: height.clamp(4.0, 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
        boxShadow: const [
          BoxShadow(
            color: Colors.white38,
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}
