import 'package:flutter/material.dart';

class FolderThemeData {
  final List<Color> gradientColors;
  final Color accentColor;
  final IconData icon;

  const FolderThemeData({
    required this.gradientColors,
    required this.accentColor,
    required this.icon,
  });
}

/// Dynamically resolves a luxury color palette and icon for music folders
FolderThemeData getFolderTheme(String folderName) {
  final lower = folderName.trim().toLowerCase();

  // 1. ALL SONGS (Signature Cosmic Violet / Nebula)
  if (lower == 'all songs' || lower == 'all' || lower == 'সব গান') {
    return const FolderThemeData(
      gradientColors: [
        Color(0xFF2E0854),
        Color(0xFF581C87),
        Color(0xFF7E22CE),
      ],
      accentColor: Color(0xFFA855F7),
      icon: Icons.all_inclusive_rounded,
    );
  }

  // 2. FAVOURITES / FAVORITES (Crimson Rose Velvet)
  if (lower.contains('favour') ||
      lower.contains('favor') ||
      lower.contains('maya') ||
      lower.contains('माया') ||
      lower.contains('heart')) {
    return const FolderThemeData(
      gradientColors: [
        Color(0xFF4C0519),
        Color(0xFF881337),
        Color(0xFFBE185D),
      ],
      accentColor: Color(0xFFFB7185),
      icon: Icons.favorite_rounded,
    );
  }

  // 3. POP / DANCE / PARTY (Cyber Cyan & Electric Indigo)
  if (lower.contains('pop') ||
      lower.contains('party') ||
      lower.contains('dance') ||
      lower.contains('remix')) {
    return const FolderThemeData(
      gradientColors: [
        Color(0xFF083344),
        Color(0xFF0E7490),
        Color(0xFF06B6D4),
      ],
      accentColor: Color(0xFF22D3EE),
      icon: Icons.bolt_rounded,
    );
  }

  // 4. BHAJAN / DEVOTIONAL / BHAKTI (Sacred Saffron & Divine Temple Gold)
  if (lower.contains('bhajan') ||
      lower.contains('bhakti') ||
      lower.contains('भजन') ||
      lower.contains('god') ||
      lower.contains('divine')) {
    return const FolderThemeData(
      gradientColors: [
        Color(0xFF5A1A00),
        Color(0xFF9A3412),
        Color(0xFFD97706),
      ],
      accentColor: Color(0xFFFDE047),
      icon: Icons.wb_sunny_rounded,
    );
  }

  // 5. LOK / FOLK / DOHORI (Warm Terracotta & Cinnamon Mahogany)
  if (lower.contains('lok') ||
      lower.contains('folk') ||
      lower.contains('dohori') ||
      lower.contains('geet') ||
      lower.contains('गीत')) {
    return const FolderThemeData(
      gradientColors: [
        Color(0xFF3F1D0B),
        Color(0xFF7C2D12),
        Color(0xFFC2410C),
      ],
      accentColor: Color(0xFFFB923C),
      icon: Icons.audiotrack_rounded,
    );
  }

  // 6. MOVIE SONGS / FILMI / CINEMA (Cinematic Emerald Jade)
  if (lower.contains('movie') ||
      lower.contains('filmi') ||
      lower.contains('cinema') ||
      lower.contains('film')) {
    return const FolderThemeData(
      gradientColors: [
        Color(0xFF064E3B),
        Color(0xFF047857),
        Color(0xFF059669),
      ],
      accentColor: Color(0xFF34D399),
      icon: Icons.movie_filter_rounded,
    );
  }

  // 7. OLD SONGS / RETRO / CLASSIC (Vintage Sepia Bronze & Antique Gold)
  if (lower.contains('old') ||
      lower.contains('retro') ||
      lower.contains('classic') ||
      lower.contains('vintage')) {
    return const FolderThemeData(
      gradientColors: [
        Color(0xFF2B1D0E),
        Color(0xFF573A1D),
        Color(0xFF855D33),
      ],
      accentColor: Color(0xFFE0B27A),
      icon: Icons.radio_rounded,
    );
  }

  // 8. HINDI SONGS / BOLLYWOOD (Bollywood Velvet Orchid & Fuchsia)
  if (lower.contains('hindi') || lower.contains('bollywood')) {
    return const FolderThemeData(
      gradientColors: [
        Color(0xFF3B0764),
        Color(0xFF701A75),
        Color(0xFFC026D3),
      ],
      accentColor: Color(0xFFF0ABFC),
      icon: Icons.music_video_rounded,
    );
  }

  // 9. ROCK / METAL / PUNK (Midnight Blue & Electric Indigo)
  if (lower.contains('rock') ||
      lower.contains('metal') ||
      lower.contains('guitar') ||
      lower.contains('heavy')) {
    return const FolderThemeData(
      gradientColors: [
        Color(0xFF1E1B4B),
        Color(0xFF3730A3),
        Color(0xFF4F46E5),
      ],
      accentColor: Color(0xFF818CF8),
      icon: Icons.electric_bolt_rounded,
    );
  }

  // 10. ROMANTIC / LOVE / SLOW (Rose Velvet Passion)
  if (lower.contains('romance') ||
      lower.contains('romantic') ||
      lower.contains('love') ||
      lower.contains('slow') ||
      lower.contains('sad')) {
    return const FolderThemeData(
      gradientColors: [
        Color(0xFF4C0519),
        Color(0xFF881337),
        Color(0xFFE11D48),
      ],
      accentColor: Color(0xFFFB7185),
      icon: Icons.volunteer_activism_rounded,
    );
  }

  // 11. NEPALI CULTURAL
  if (lower.contains('nepali')) {
    return const FolderThemeData(
      gradientColors: [
        Color(0xFF14532D),
        Color(0xFF15803D),
        Color(0xFF22C55E),
      ],
      accentColor: Color(0xFF4ADE80),
      icon: Icons.library_music_rounded,
    );
  }

  // 12. DOWNLOADS / OFFLINE (Deep Slate & Sky Blue)
  if (lower.contains('download') || lower.contains('offline')) {
    return const FolderThemeData(
      gradientColors: [
        Color(0xFF0F172A),
        Color(0xFF1E293B),
        Color(0xFF334155),
      ],
      accentColor: Color(0xFF38BDF8),
      icon: Icons.download_done_rounded,
    );
  }

  // 9. DETERMINISTIC ROTATING PALETTES for any other folder name
  const curatedThemes = [
    FolderThemeData(
      gradientColors: [Color(0xFF311042), Color(0xFF581C87), Color(0xFF7E22CE)],
      accentColor: Color(0xFFA855F7),
      icon: Icons.album_rounded,
    ),
    FolderThemeData(
      gradientColors: [Color(0xFF082F49), Color(0xFF0369A1), Color(0xFF0284C7)],
      accentColor: Color(0xFF38BDF8),
      icon: Icons.graphic_eq_rounded,
    ),
    FolderThemeData(
      gradientColors: [Color(0xFF431407), Color(0xFF9A3412), Color(0xFFC2410C)],
      accentColor: Color(0xFFFB923C),
      icon: Icons.music_note_rounded,
    ),
    FolderThemeData(
      gradientColors: [Color(0xFF064E3B), Color(0xFF065F46), Color(0xFF047857)],
      accentColor: Color(0xFF34D399),
      icon: Icons.library_music_rounded,
    ),
    FolderThemeData(
      gradientColors: [Color(0xFF4C0519), Color(0xFF881337), Color(0xFFBE185D)],
      accentColor: Color(0xFFFB7185),
      icon: Icons.stars_rounded,
    ),
    FolderThemeData(
      gradientColors: [Color(0xFF172554), Color(0xFF1D4ED8), Color(0xFF2563EB)],
      accentColor: Color(0xFF60A5FA),
      icon: Icons.headphones_rounded,
    ),
    FolderThemeData(
      gradientColors: [Color(0xFF2E1065), Color(0xFF6B21A8), Color(0xFF9333EA)],
      accentColor: Color(0xFFC084FC),
      icon: Icons.auto_awesome_rounded,
    ),
    FolderThemeData(
      gradientColors: [Color(0xFF18181B), Color(0xFF27272A), Color(0xFF3F3F46)],
      accentColor: Color(0xFFA1A1AA),
      icon: Icons.folder_special_rounded,
    ),
  ];

  final index = folderName.hashCode.abs() % curatedThemes.length;
  return curatedThemes[index];
}

