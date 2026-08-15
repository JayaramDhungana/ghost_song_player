import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/player/player_bloc.dart';
import '../../blocs/player/player_event.dart';
import '../../blocs/player/player_state.dart';
import '../../models/song.dart';

class NowPlaying extends StatelessWidget {
  final Song song;
  final PlayerState state;

  const NowPlaying({
    super.key,
    required this.song,
    required this.state,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.08),
      ),
      child: Column(
        children: [
          Text(
            song.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            song.artist ?? 'Unknown Artist',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 10),

          Column(
            children: [
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
                          SeekSong(
                            Duration(
                              milliseconds: value.toInt(),
                            ),
                          ),
                        );
                      },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(state.position)),
                    Text(_formatDuration(state.duration)),
                  ],
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 32,
                onPressed: state.status == PlayerStatus.loading
                    ? null
                    : () {
                        context.read<PlayerBloc>().add(
                          const PreviousSong(),
                        );
                      },
                icon: const Icon(Icons.skip_previous),
              ),

              const SizedBox(width: 20),

              IconButton(
                iconSize: 52,
                onPressed: state.status == PlayerStatus.loading
                    ? null
                    : () {
                        context.read<PlayerBloc>().add(
                          const TogglePlayPause(),
                        );
                      },
                icon: state.status == PlayerStatus.loading
                    ? const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                        ),
                      )
                    : Icon(
                        state.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                      ),
              ),

              const SizedBox(width: 20),

              IconButton(
                iconSize: 32,
                onPressed: state.status == PlayerStatus.loading
                    ? null
                    : () {
                        context.read<PlayerBloc>().add(
                          const NextSong(),
                        );
                      },
                icon: const Icon(Icons.skip_next),
              ),
            ],
          ),

          Row(
            children: [
              const Icon(Icons.volume_down),

              Expanded(
                child: Slider(
                  value: state.volume,
                  min: 0,
                  max: 1,
                  onChanged: (value) {
                    context.read<PlayerBloc>().add(
                      SetVolume(value),
                    );
                  },
                ),
              ),

              const Icon(Icons.volume_up),
            ],
          ),
        ],
      ),
    );
  }
}