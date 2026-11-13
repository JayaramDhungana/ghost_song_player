import 'dart:ui';
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
import '../../utils/download_helper/download_helper.dart';
import 'download_view.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({super.key});

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  late final Playlist playlist;

  final ValueNotifier<bool> _isUiVisible = ValueNotifier(false);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
          key: _scaffoldKey,
          endDrawerEnableOpenDragGesture: true,
          endDrawer: const _GlassSideDrawer(),
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
                              Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 44),
                                        Expanded(
                                          child: Center(
                                            child: ShaderMask(
                                              shaderCallback: (bounds) => const LinearGradient(
                                                colors: [
                                                  Colors.white,
                                                  Color(0xFFE0E7FF),
                                                  Color(0xFFC084FC),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ).createShader(bounds),
                                              child: const Text(
                                                'JD MEDIA PLAYER',
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 2.2,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF161524).withValues(alpha: 0.8),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white.withValues(alpha: 0.1),
                                              width: 1.2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.3),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.menu_rounded,
                                              size: 22,
                                              color: Colors.white70,
                                            ),
                                            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                                            tooltip: 'Menu',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
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
                                    const SizedBox(height: 50),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 48),
                                          Expanded(
                                            child: Center(
                                              child: ShaderMask(
                                                shaderCallback: (bounds) => const LinearGradient(
                                                  colors: [
                                                    Colors.white,
                                                    Color(0xFFE0E7FF),
                                                    Color(0xFFC084FC),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ).createShader(bounds),
                                                child: const Text(
                                                  'JD MEDIA PLAYER',
                                                  style: TextStyle(
                                                    fontSize: 26,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 2.8,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 46,
                                            height: 46,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF161524).withValues(alpha: 0.8),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white.withValues(alpha: 0.1),
                                                width: 1.2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.3),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.menu_rounded,
                                                size: 24,
                                                color: Colors.white70,
                                              ),
                                              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                                              tooltip: 'Menu',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Expanded(child: MusicLibrary()),
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

// ═════════════════════════════════════════════════════════════════
// FROSTED GLASS SIDE DRAWER
// ═════════════════════════════════════════════════════════════════
class _GlassSideDrawer extends StatelessWidget {
  const _GlassSideDrawer();

  void _showInstallInfo(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181628),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Color(0xFFC084FC), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFFC084FC), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final drawerWidth = width > 420 ? 360.0 : width * 0.85;

    return Drawer(
      elevation: 0,
      backgroundColor: Colors.transparent,
      width: drawerWidth,
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F0E17).withValues(alpha: 0.94),
              border: Border(
                left: BorderSide(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.2,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top Header
                  _buildHeader(context),
                  const Divider(color: Colors.white10, height: 1),

                  // Scrollable Body
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      children: [
                        // Section: Get The Apps
                        _buildSectionHeader('GET THE APPS', Icons.devices_rounded),
                        const SizedBox(height: 10),
                        _buildAppDownloadCard(
                          context,
                          title: 'Android App',
                          subtitle: 'Direct .apk package for mobile',
                          badge: 'v1.0 APK',
                          icon: Icons.android_rounded,
                          accentColor: const Color(0xFF3DDC84),
                          onTap: () {
                            triggerAppDownload('downloads/JD_Media_Player.apk', 'JD_Media_Player.apk');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF1E1B2E),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                content: const Row(
                                  children: [
                                    Icon(Icons.downloading_rounded, color: Color(0xFF3DDC84)),
                                    SizedBox(width: 12),
                                    Expanded(child: Text('Downloading JD Media Player Android APK...')),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildAppDownloadCard(
                          context,
                          title: 'Windows App',
                          subtitle: 'Portable desktop player for PC',
                          badge: 'v1.0 ZIP',
                          icon: Icons.laptop_windows_rounded,
                          accentColor: const Color(0xFF00A4EF),
                          onTap: () {
                            triggerAppDownload('downloads/JD_Media_Player_Windows.zip', 'JD_Media_Player_Windows.zip');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF1E1B2E),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                content: const Row(
                                  children: [
                                    Icon(Icons.downloading_rounded, color: Color(0xFF00A4EF)),
                                    SizedBox(width: 12),
                                    Expanded(child: Text('Downloading JD Media Player Windows ZIP...')),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 22),

                        // Section: Offline Playback
                        _buildSectionHeader('OFFLINE PLAYBACK', Icons.cloud_done_rounded),
                        const SizedBox(height: 10),
                        _buildActionTile(
                          icon: Icons.cloud_download_rounded,
                          iconColor: const Color(0xFFA855F7),
                          title: 'Download All Songs',
                          subtitle: 'Save songs for offline listening',
                          onTap: () {
                            Navigator.of(context).pop(); // Close drawer
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DownloadView()),
                            );
                          },
                        ),

                        const SizedBox(height: 22),

                        // Section: Sort By
                        _buildSectionHeader('SORT SONGS BY', Icons.sort_rounded),
                        const SizedBox(height: 8),
                        BlocBuilder<LibraryBloc, LibraryState>(
                          builder: (ctx, state) {
                            return Column(
                              children: [
                                _buildSortOption(
                                  ctx,
                                  title: 'Time Added (Newest First)',
                                  icon: Icons.access_time_filled_rounded,
                                  mode: SortMode.timeAddedDesc,
                                  current: state.sortMode,
                                ),
                                const SizedBox(height: 6),
                                _buildSortOption(
                                  ctx,
                                  title: 'Time Added (Oldest First)',
                                  icon: Icons.access_time_rounded,
                                  mode: SortMode.timeAddedAsc,
                                  current: state.sortMode,
                                ),
                                const SizedBox(height: 6),
                                _buildSortOption(
                                  ctx,
                                  title: 'Alphabetical (A → Z)',
                                  icon: Icons.sort_by_alpha_rounded,
                                  mode: SortMode.alphabeticalAsc,
                                  current: state.sortMode,
                                ),
                                const SizedBox(height: 6),
                                _buildSortOption(
                                  ctx,
                                  title: 'Alphabetical (Z → A)',
                                  icon: Icons.sort_by_alpha_rounded,
                                  mode: SortMode.alphabeticalDesc,
                                  current: state.sortMode,
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 28),

                        // Section: Dedication Badge
                        _buildDedicationBadge(),

                        const SizedBox(height: 16),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
      child: Row(
        children: [
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Colors.white,
                  Color(0xFFE0E7FF),
                  Color(0xFFC084FC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Text(
                'JD MEDIA PLAYER',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close Menu',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFFC084FC)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildAppDownloadCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badge,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF161524).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF161524).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Colors.white38,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required SortMode mode,
    required SortMode current,
  }) {
    final isSelected = mode == current;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          context.read<LibraryBloc>().add(SortSongs(mode));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFC084FC).withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFC084FC).withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? const Color(0xFFC084FC) : Colors.white54,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: Color(0xFFC084FC),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDedicationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFC084FC).withValues(alpha: 0.12),
            const Color(0xFFE879F9).withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC084FC).withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC084FC).withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.redAccent.withValues(alpha: 0.15),
              border: Border.all(
                color: Colors.redAccent.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Center(
              child: Text(
                '❤️',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Specially crafted with love',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Renuka Dhungana (Bahini)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF472B6),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
