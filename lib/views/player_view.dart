import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghost_song_player/blocs/library/library_bloc.dart';
import 'package:ghost_song_player/blocs/library/library_event.dart';
import 'package:ghost_song_player/data/music_library.dart';
import 'package:ghost_song_player/widgets/library/music_library.dart';
import 'package:ghost_song_player/widgets/player/now_playing.dart';
import 'package:ghost_song_player/widgets/player/secret_ui_toggle.dart';

import '../blocs/player/player_bloc.dart';
import '../blocs/player/player_event.dart';
import '../blocs/player/player_state.dart';
import '../models/playlist.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({super.key});

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  late final Playlist playlist;
  final ValueNotifier<bool> _isUiVisible = ValueNotifier(false);

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
                child: BlocBuilder<PlayerBloc, PlayerState>(
                  builder: (context, state) {
                    final currentSong = state.currentSong;

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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
