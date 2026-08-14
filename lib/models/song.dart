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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'audioUrl': audioUrl,
      'coverUrl': coverUrl,
      'folder': folder,
    };
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String?,
      audioUrl: json['audioUrl'] as String,
      coverUrl: json['coverUrl'] as String?,
      folder: json['folder'] as String,
    );
  }
}