import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/library/library_bloc.dart';
import '../../blocs/library/library_event.dart';
import '../../blocs/library/library_state.dart';
import '../../blocs/player/player_bloc.dart';
import '../../blocs/player/player_event.dart';
import '../../blocs/player/player_state.dart';
import '../../views/folder_detail_view.dart';

class MusicLibrary extends StatelessWidget {
  const MusicLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            labelColor: Theme.of(context).colorScheme.onPrimaryContainer,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Songs'),
              Tab(text: 'Folders'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                _buildSongsTab(context),
                _buildFoldersTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsTab(BuildContext context) {
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      context.read<LibraryBloc>().add(SearchSongs(value));
                    },
                  ),
                ),
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
                                    bloc.add(PlaySong(song, playlist: libraryState.filteredSongs));
                                  }
                                },
                              ),
                              onTap: () {
                                final bloc = context.read<PlayerBloc>();
                                if (!isCurrentSong) {
                                  bloc.add(PlaySong(song, playlist: libraryState.filteredSongs));
                                }
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

  Widget _buildFoldersTab(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        final folders = state.songs
            .expand((song) => song.folders)
            .toSet()
            .toList();

        if (folders.isEmpty) {
          return const Center(child: Text('No folders available'));
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: folders.length + 1, // +1 for "All Songs"
          itemBuilder: (context, index) {
            // First card = "All Songs"
            if (index == 0) {
              return _FolderCard(
                folderName: 'All Songs',
                songCount: state.songs.length,
                icon: Icons.library_music_rounded,
                gradientColors: const [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<LibraryBloc>(),
                        child: FolderDetailView(
                          folderName: 'All Songs',
                          songs: state.songs,
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            final folderName = folders[index - 1];
            final folderSongs = state.songs
                .where((song) => song.folders.contains(folderName))
                .toList();

            return _FolderCard(
              folderName: folderName,
              songCount: folderSongs.length,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<LibraryBloc>(),
                      child: FolderDetailView(
                        folderName: folderName,
                        songs: folderSongs,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _FolderCard extends StatelessWidget {
  final String folderName;
  final int songCount;
  final VoidCallback onTap;
  final IconData icon;
  final List<Color>? gradientColors;

  const _FolderCard({
    required this.folderName,
    required this.songCount,
    required this.onTap,
    this.icon = Icons.folder_special_rounded,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ??
        const [
          Color(0xFF24243E),
          Color(0xFF302B63),
          Color(0xFF0F0C29),
        ];

    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'folder_hero_$folderName',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icon,
                    size: 60,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        folderName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$songCount Songs',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
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
  }
}
