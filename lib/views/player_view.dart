import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/player/player_bloc.dart';
import '../blocs/player/player_event.dart';
import '../blocs/player/player_state.dart';
import '../models/playlist.dart';
import '../models/song.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({super.key});

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  late final Playlist playlist;

  @override
  void initState() {
    super.initState();

    playlist = Playlist(
      id: 'nepali',
      name: 'Nepali Songs',
      songs: const [
        Song(
          id: 'basyo-maya',
          title: 'BASYO MAYA',
          artist: 'Local',
          audioUrl: 'asset://audio/BASYO_MAYA(128k).mp3',
          folder: 'Nepali',
        ),

        Song(
          id: 'song-two',
          title: 'Gauri',
          artist: 'Local',
          audioUrl: 'asset://audio/Gauri.mp3',
          folder: 'Nepali',
        ),

        Song(
          id: 'song-three',
          title: 'Nuwakote Yo Jhilke Keto',
          artist: 'Local',
          audioUrl: 'asset://audio/nuwakote_yo_jhilke.mp3',
          folder: 'Nepali',
        ),
      ],
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerBloc>().add(LoadPlaylist(playlist.songs));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<PlayerBloc, PlayerState>(
          builder: (context, state) {
            final currentSong = state.currentSong;

            return Center(
              child: SizedBox(
                width: 600,
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    Text(
                      playlist.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Expanded(
                      child: ListView.builder(
                        itemCount: playlist.songs.length,
                        itemBuilder: (context, index) {
                          final song = playlist.songs[index];

                          final isCurrentSong = currentSong?.id == song.id;

                          return ListTile(
                            selected: isCurrentSong,
                            leading: Icon(
                              isCurrentSong && state.isPlaying
                                  ? Icons.equalizer
                                  : Icons.music_note,
                            ),
                            title: Text(song.title),
                            subtitle: Text(song.artist ?? 'Unknown Artist'),
                            trailing: IconButton(
                              onPressed: state.status == PlayerStatus.loading
                                  ? null
                                  : () {
                                      final bloc = context.read<PlayerBloc>();

                                      if (isCurrentSong) {
                                        bloc.add(const TogglePlayPause());
                                      } else {
                                        bloc.add(PlaySong(song));
                                      }
                                    },
                              icon:
                                  state.status == PlayerStatus.loading &&
                                      isCurrentSong
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      isCurrentSong && state.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                            ),
                            onTap: () {
                              context.read<PlayerBloc>().add(PlaySong(song));
                            },
                          );
                        },
                      ),
                    ),

                    if (currentSong != null) ...[
                      _NowPlaying(song: currentSong, state: state),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NowPlaying extends StatelessWidget {
  final Song song;
  final PlayerState state;

  const _NowPlaying({required this.song, required this.state});

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
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(
            song.artist ?? 'Unknown Artist',
            style: const TextStyle(color: Colors.grey),
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
                          SeekSong(Duration(milliseconds: value.toInt())),
                        );
                      },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                onPressed: () {
                  context.read<PlayerBloc>().add(const PreviousSong());
                },
                icon: const Icon(Icons.skip_previous),
              ),

              const SizedBox(width: 20),

              IconButton(
                iconSize: 52,
                onPressed: state.status == PlayerStatus.loading
                    ? null
                    : () {
                        context.read<PlayerBloc>().add(const TogglePlayPause());
                      },
                icon: state.status == PlayerStatus.loading
                    ? const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(strokeWidth: 3),
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
                onPressed: () {
                  context.read<PlayerBloc>().add(const NextSong());
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
                    context.read<PlayerBloc>().add(SetVolume(value));
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
