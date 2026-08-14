class Song {
  final String id;
  final String title;
  final String? artist;
  final String audioUrl;
  final String? coverUrl;
  final String folder;

  const Song({
    required this.id,
    required this.title,
    this.artist,
    required this.audioUrl,
    this.coverUrl,
    required this.folder,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? audioUrl,
    String? coverUrl,
    String? folder,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      audioUrl: audioUrl ?? this.audioUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      folder: folder ?? this.folder,
    );
  }
}
