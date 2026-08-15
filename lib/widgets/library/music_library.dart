import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/library/library_bloc.dart';
import '../../blocs/library/library_event.dart';
import '../../blocs/library/library_state.dart';
import '../../blocs/player/player_bloc.dart';
import '../../blocs/player/player_event.dart';
import '../../blocs/player/player_state.dart';

class MusicLibrary extends StatelessWidget {
  const MusicLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, libraryState) {
        return BlocBuilder<PlayerBloc, PlayerState>(
          builder: (context, playerState) {
            final currentSong = playerState.currentSong;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search songs...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onChanged: (value) {
                      context.read<LibraryBloc>().add(SearchSongs(value));
                    },
                  ),
                ),

                const SizedBox(height: 16),
                const SizedBox(height: 16),

                _FolderFilters(state: libraryState),

                const SizedBox(height: 16),

                Expanded(
                  child: libraryState.filteredSongs.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.music_off,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No songs found',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: libraryState.filteredSongs.length,
                          itemBuilder: (context, index) {
                            final song = libraryState.filteredSongs[index];

                            final isCurrentSong = currentSong?.id == song.id;

                            return ListTile(
                              selected: isCurrentSong,

                              leading: Icon(
                                isCurrentSong && playerState.isPlaying
                                    ? Icons.equalizer
                                    : Icons.music_note,
                              ),

                              title: Text(song.title),

                              subtitle: Text(song.artist ?? 'Unknown Artist'),

                              trailing: IconButton(
                                icon: Icon(
                                  isCurrentSong && playerState.isPlaying
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
              ],
            );
          },
        );
      },
    );
  }
}

class _FolderFilters extends StatelessWidget {
  final LibraryState state;

  const _FolderFilters({required this.state});

  @override
  Widget build(BuildContext context) {
    final folders = state.songs
        .expand((song) => song.folders)
        .toSet()
        .toList();

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: state.selectedFolder == null,
            onSelected: (_) {
              context.read<LibraryBloc>().add(
                const FilterByFolder(null),
              );
            },
          ),

          const SizedBox(width: 8),

          ...folders.map(
            (folder) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(folder),
                selected: state.selectedFolder == folder,
                onSelected: (_) {
                  context.read<LibraryBloc>().add(
                    FilterByFolder(folder),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
