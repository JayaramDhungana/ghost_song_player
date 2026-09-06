import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/library/library_bloc.dart';
import '../../blocs/library/library_event.dart';
import '../../blocs/library/library_state.dart';
import '../../blocs/player/player_bloc.dart';
import '../../blocs/player/player_event.dart';
import '../../blocs/player/player_state.dart';
import '../../data/music_library.dart';
import '../../models/playlist.dart';
import '../../models/song.dart';
import '../../widgets/library/music_library.dart';
import '../../widgets/player/mini_player.dart';
import '../../widgets/player/now_playing.dart';
import '../../widgets/player/secret_ui_toggle.dart';

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

  void _openSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: context.read<LibraryBloc>(),
          child: BlocBuilder<LibraryBloc, LibraryState>(
            builder: (ctx, libState) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'SORT BY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _sortOption(
                      ctx,
                      icon: Icons.access_time,
                      label: 'Time Added (Oldest First)',
                      mode: SortMode.timeAddedAsc,
                      current: libState.sortMode,
                    ),
                    _sortOption(
                      ctx,
                      icon: Icons.access_time_filled,
                      label: 'Time Added (Newest First)',
                      mode: SortMode.timeAddedDesc,
                      current: libState.sortMode,
                    ),
                    _sortOption(
                      ctx,
                      icon: Icons.sort_by_alpha,
                      label: 'Alphabetical (A → Z)',
                      mode: SortMode.alphabeticalAsc,
                      current: libState.sortMode,
                    ),
                    _sortOption(
                      ctx,
                      icon: Icons.sort_by_alpha,
                      label: 'Alphabetical (Z → A)',
                      mode: SortMode.alphabeticalDesc,
                      current: libState.sortMode,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _sortOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required SortMode mode,
    required SortMode current,
  }) {
    final isSelected = mode == current;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 20)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        context.read<LibraryBloc>().add(SortSongs(mode));
        Navigator.of(context).pop();
      },
    );
  }

  void _openMobilePlayer(BuildContext context, Song song, PlayerState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MobileFullPlayer(song: song, state: state),
    );
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

                    return BlocBuilder<PlayerBloc, PlayerState>(
                      builder: (context, state) {
                        final currentSong = state.currentSong;

                        // ═════════════════════════════════════
                        // MOBILE
                        // ═════════════════════════════════════
                        if (isMobile) {
                          return Stack(
                            children: [
                              // Normal mobile library + mini player
                              Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'JD MEDIA PLAYER',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.settings, size: 22),
                                        onPressed: () => _openSettings(context),
                                        tooltip: 'Settings',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Expanded(child: MusicLibrary()),
                                  if (currentSong != null)
                                    MiniPlayer(
                                      song: currentSong,
                                      state: state,
                                      onTap: () => _openMobilePlayer(
                                        context,
                                        currentSong,
                                        state,
                                      ),
                                    ),
                                ],
                              ),
                              // Loading toast overlay
                              const SongLoadingToast(),
                            ],
                          );
                        }

                        // ═════════════════════════════════════
                        // DESKTOP
                        // ═════════════════════════════════════
                        return Stack(
                          children: [
                            Center(
                              child: SizedBox(
                                width: 600,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 60),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'JD MEDIA PLAYER',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.settings, size: 24),
                                          onPressed: () => _openSettings(context),
                                          tooltip: 'Settings',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    const Expanded(child: MusicLibrary()),
                                    // if (currentSong != null)
                                    //   NowPlaying(
                                    //     song: currentSong,
                                    //     state: state,
                                    //   ),
                                    if (currentSong != null)
                                      DesktopMiniPlayer(
                                        song: currentSong,
                                        state: state,
                                        onTap: () => _openMobilePlayer(
                                          context,
                                          currentSong,
                                          state,
                                        ),
                                      ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                            // Loading toast overlay
                            const SongLoadingToast(),
                          ],
                        );
                      },
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
