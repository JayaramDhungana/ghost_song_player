import 'song.dart';

class Playlist {
  final String id;
  final String name;
  final List<Song> songs;
  final String? coverUrl;

  const Playlist({
    required this.id,
    required this.name,
    this.songs = const [],
    this.coverUrl,
  });

  Playlist copyWith({
    String? id,
    String? name,
    List<Song>? songs,
    String? coverUrl,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      songs: songs ?? this.songs,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'songs': songs.map((song) => song.toJson()).toList(),
      'coverUrl': coverUrl,
    };
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final songsJson = json['songs'] as List<dynamic>? ?? [];

    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      songs: songsJson
          .map(
            (song) => Song.fromJson(
              song as Map<String, dynamic>,
            ),
          )
          .toList(),
      coverUrl: json['coverUrl'] as String?,
    );
  }
}