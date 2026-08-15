class Song {
  final String id;
  final String title;
  final String? artist;
  final String audioUrl;
  final String? coverUrl;
  final List<String> folders;

  const Song({
    required this.id,
    required this.title,
    this.artist,
    required this.audioUrl,
    this.coverUrl,
    this.folders = const [],
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? audioUrl,
    String? coverUrl,
    List<String>? folders,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      audioUrl: audioUrl ?? this.audioUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      folders: folders ?? this.folders,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'audioUrl': audioUrl,
      'coverUrl': coverUrl,
      'folders': folders,
    };
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String?,
      audioUrl: json['audioUrl'] as String,
      coverUrl: json['coverUrl'] as String?,
      folders: (json['folders'] as List<dynamic>? ?? [])
          .map((folder) => folder.toString())
          .toList(),
    );
  }
}