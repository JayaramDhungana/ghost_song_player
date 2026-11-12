import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/library/library_bloc.dart';
import '../../blocs/library/library_event.dart';
import '../../blocs/library/library_state.dart';
import '../../blocs/player/player_bloc.dart';
import '../../blocs/player/player_event.dart';
import '../../blocs/player/player_state.dart';
import '../../models/folder_theme.dart';
import '../../views/folder_detail_view.dart';
import 'song_tile.dart';

class MusicLibrary extends StatefulWidget {
  const MusicLibrary({super.key});

  @override
  State<MusicLibrary> createState() => _MusicLibraryState();
}

class _MusicLibraryState extends State<MusicLibrary> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // ═══════════════════════════════════════════════
          // FLOATING GLASSMORPHIC SEGMENTED CAPSULE (TABS)
          // ═══════════════════════════════════════════════
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF13121E).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6366F1), // Electric Indigo
                      Color(0xFFA855F7), // Royal Violet
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA855F7).withValues(alpha: 0.45),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                labelColor: Colors.white,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                ),
                unselectedLabelColor: Colors.grey.shade400,
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                tabs: const [
                  Tab(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.music_note_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Songs'),
                      ],
                    ),
                  ),
                  Tab(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Folders'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                _SongsTabView(searchController: _searchController),
                const _FoldersTabView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// SONGS TAB VIEW (WITH AUTOMATIC KEEP-ALIVE & SCROLL MEMORY)
// ═══════════════════════════════════════════════

class _SongsTabView extends StatefulWidget {
  final TextEditingController searchController;

  const _SongsTabView({required this.searchController});

  @override
  State<_SongsTabView> createState() => _SongsTabViewState();
}

class _SongsTabViewState extends State<_SongsTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, libraryState) {
        return BlocBuilder<PlayerBloc, PlayerState>(
          builder: (context, playerState) {
            final currentSong = playerState.currentSong;

            return Column(
              children: [
                // ═══════════════════════════════════════════════
                // ULTRA-SLEEK OBSIDIAN GLASS SEARCH BAR
                // ═══════════════════════════════════════════════
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF151422).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: widget.searchController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search songs or artists...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFFA855F7), // Neon Royal Violet Accent
                          size: 21,
                        ),
                        suffixIcon: widget.searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  widget.searchController.clear();
                                  context.read<LibraryBloc>().add(const SearchSongs(''));
                                  setState(() {});
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 13,
                          horizontal: 16,
                        ),
                      ),
                      onChanged: (value) {
                        context.read<LibraryBloc>().add(SearchSongs(value));
                        setState(() {});
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: libraryState.filteredSongs.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.music_off_rounded,
                                size: 52,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No songs found',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          key: const PageStorageKey<String>('songs_list_page_storage_key'),
                          padding: const EdgeInsets.only(bottom: 24, top: 2),
                          itemCount: libraryState.filteredSongs.length,
                          itemBuilder: (context, index) {
                            final song = libraryState.filteredSongs[index];
                            final isCurrentSong = currentSong?.id == song.id;

                            return SongTile(
                              song: song,
                              isCurrentSong: isCurrentSong,
                              isPlaying: isCurrentSong && playerState.isPlaying,
                              onTap: () {
                                final bloc = context.read<PlayerBloc>();
                                if (!isCurrentSong) {
                                  bloc.add(
                                    PlaySong(
                                      song,
                                      playlist: libraryState.filteredSongs,
                                    ),
                                  );
                                } else {
                                  bloc.add(const TogglePlayPause());
                                }
                              },
                              onPlayPause: () {
                                final bloc = context.read<PlayerBloc>();
                                if (isCurrentSong) {
                                  bloc.add(const TogglePlayPause());
                                } else {
                                  bloc.add(
                                    PlaySong(
                                      song,
                                      playlist: libraryState.filteredSongs,
                                    ),
                                  );
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
}

// ═══════════════════════════════════════════════
// FOLDERS TAB VIEW (WITH AUTOMATIC KEEP-ALIVE & SCROLL MEMORY)
// ═══════════════════════════════════════════════

class _FoldersTabView extends StatefulWidget {
  const _FoldersTabView();

  @override
  State<_FoldersTabView> createState() => _FoldersTabViewState();
}

class _FoldersTabViewState extends State<_FoldersTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        final folders = state.songs
            .expand((song) => song.folders)
            .toSet()
            .toList();

        if (folders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.folder_off_rounded,
                  size: 52,
                  color: Colors.grey,
                ),
                SizedBox(height: 12),
                Text(
                  'No folders available',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          key: const PageStorageKey<String>('folders_grid_page_storage_key'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.34, // Compact & Modern Widescreen Aspect Ratio
          ),
          itemCount: folders.length + 1, // +1 for "All Songs"
          itemBuilder: (context, index) {
            // First card = "All Songs"
            if (index == 0) {
              return _FolderCard(
                folderName: 'All Songs',
                songCount: state.songs.length,
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

// ═══════════════════════════════════════════════
// MODERN COMPACT GLASS FOLDER CARD (OPTION 1)
// ═══════════════════════════════════════════════

class _FolderCard extends StatelessWidget {
  final String folderName;
  final int songCount;
  final VoidCallback onTap;

  const _FolderCard({
    required this.folderName,
    required this.songCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = getFolderTheme(folderName);

    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'folder_hero_$folderName',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: theme.gradientColors,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.accentColor.withValues(alpha: 0.22),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  // Subtle Faint Large Watermark Icon in background
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(
                      theme.icon,
                      size: 78,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),

                  // Content Padding
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top Row: Frosted Glass Icon Badge + Subtle Play Arrow
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.accentColor.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                theme.icon,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.22),
                              ),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                size: 18,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),

                        // Bottom Section: Folder Title + Pill Count
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              folderName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.32),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.10),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                '$songCount Songs',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
