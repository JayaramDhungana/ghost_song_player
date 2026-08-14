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
          audioUrl: 'asset://assets/audio/BASYO_MAYA(128k).mp3',
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
                              icon: Icon(
                                isCurrentSong && state.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                              onPressed: () {
                                final bloc = context.read<PlayerBloc>();

                                if (isCurrentSong) {
                                  bloc.add(const TogglePlayPause());
                                } else {
                                  bloc.add(PlaySong(song));
                                }
                              },
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
                onPressed: () {
                  context.read<PlayerBloc>().add(const TogglePlayPause());
                },
                icon: Icon(
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
