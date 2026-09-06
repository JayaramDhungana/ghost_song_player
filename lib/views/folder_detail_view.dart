import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/library/library_bloc.dart';
import '../blocs/library/library_event.dart';
import '../blocs/library/library_state.dart';
import '../blocs/player/player_bloc.dart';
import '../blocs/player/player_event.dart';
import '../blocs/player/player_state.dart';
import '../models/song.dart';
import '../widgets/player/mini_player.dart';

class FolderDetailView extends StatefulWidget {
  final String folderName;
  final List<Song> songs;

  const FolderDetailView({
    super.key,
    required this.folderName,
    required this.songs,
  });

  @override
  State<FolderDetailView> createState() => _FolderDetailViewState();
}

class _FolderDetailViewState extends State<FolderDetailView> {
  String _searchQuery = '';

  void _openMobilePlayer(BuildContext context, Song song, PlayerState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MobileFullPlayer(song: song, state: state),
    );
  }

  List<Song> _filterAndSortSongs(List<Song> songs, SortMode sortMode) {
    final filtered = _searchQuery.trim().isEmpty
        ? List<Song>.from(songs)
        : songs.where((s) {
            final q = _searchQuery.trim().toLowerCase();
            return s.title.toLowerCase().contains(q) ||
                (s.artist?.toLowerCase().contains(q) ?? false);
          }).toList();

    switch (sortMode) {
      case SortMode.timeAddedAsc:
        return filtered; // Original order
      case SortMode.timeAddedDesc:
        return filtered.reversed.toList();
      case SortMode.alphabeticalAsc:
        filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        return filtered;
      case SortMode.alphabeticalDesc:
        filtered.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        return filtered;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            return BlocBuilder<LibraryBloc, LibraryState>(
              buildWhen: (prev, curr) => prev.sortMode != curr.sortMode,
              builder: (context, libState) {
                final sortedSongs = _filterAndSortSongs(widget.songs, libState.sortMode);

                return BlocBuilder<PlayerBloc, PlayerState>(
                  builder: (context, playerState) {
                    final currentSong = playerState.currentSong;

                    Widget scrollContent = CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 250.0,
                      floating: false,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          widget.folderName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 4.0,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                        background: Hero(
                          tag: 'folder_hero_${widget.folderName}',
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF24243E),
                                  Color(0xFF302B63),
                                  Color(0xFF0F0C29),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.folder_special_rounded,
                                size: 80,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Search in folder...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 28),
                          label: const Text(
                            'PLAY ALL',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          onPressed: () {
                            if (sortedSongs.isNotEmpty) {
                              final bloc = context.read<PlayerBloc>();
                              bloc.add(PlaySong(sortedSongs.first, playlist: sortedSongs));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final song = sortedSongs[index];
                        final isCurrentSong = currentSong?.id == song.id;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 4,
                          ),
                          selected: isCurrentSong,
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isCurrentSong && playerState.isPlaying
                                  ? Icons.equalizer
                                  : Icons.music_note,
                              color: isCurrentSong
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                          ),
                          title: Text(
                            song.title,
                            style: TextStyle(
                              fontWeight: isCurrentSong
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isCurrentSong
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                          ),
                          subtitle: Text(song.artist ?? 'Unknown Artist'),
                          trailing: IconButton(
                            icon: Icon(
                              isCurrentSong && playerState.isPlaying
                                  ? Icons.pause_circle_filled_rounded
                                  : Icons.play_circle_fill_rounded,
                              size: 32,
                            ),
                            onPressed: () {
                              final bloc = context.read<PlayerBloc>();

                              if (isCurrentSong) {
                                bloc.add(const TogglePlayPause());
                              } else {
                                bloc.add(PlaySong(song, playlist: sortedSongs));
                              }
                            },
                          ),
                          onTap: () {
                            final bloc = context.read<PlayerBloc>();
                            if (!isCurrentSong) {
                              bloc.add(PlaySong(song, playlist: sortedSongs));
                            }
                          },
                        );
                      }, childCount: sortedSongs.length),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100), // Padding for mini player
                    ),
                  ],
                );

                if (isMobile) {
                  return Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(child: scrollContent),
                          if (currentSong != null)
                            MiniPlayer(
                              song: currentSong,
                              state: playerState,
                              onTap: () => _openMobilePlayer(
                                context,
                                currentSong,
                                playerState,
                              ),
                            ),
                        ],
                      ),
                      const SongLoadingToast(),
                    ],
                  );
                }

                // Desktop Layout
                return Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 600,
                        child: Column(
                          children: [
                            Expanded(child: scrollContent),
                            if (currentSong != null)
                              DesktopMiniPlayer(
                                song: currentSong,
                                state: playerState,
                                onTap: () => _openMobilePlayer(
                                  context,
                                  currentSong,
                                  playerState,
                                ),
                              ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    const SongLoadingToast(),
                  ],
                );
              },
            );
          },
            );
          }
        )
      ),
    );
  }
}
