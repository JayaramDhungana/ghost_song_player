import '../../models/song.dart';

class LibraryState {
  final List<Song> songs;
  final List<Song> filteredSongs;
  final String searchQuery;
  final String? selectedFolder;
  final bool isLoading;

  const LibraryState({
    this.songs = const [],
    this.filteredSongs = const [],
    this.searchQuery = '',
    this.selectedFolder,
    this.isLoading = false,
  });

  LibraryState copyWith({
    List<Song>? songs,
    List<Song>? filteredSongs,
    String? searchQuery,
    Object? selectedFolder = _noChange,
    bool? isLoading,
  }) {
    return LibraryState(
      songs: songs ?? this.songs,
      filteredSongs: filteredSongs ?? this.filteredSongs,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFolder: selectedFolder == _noChange
          ? this.selectedFolder
          : selectedFolder as String?,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

const _noChange = Object();
