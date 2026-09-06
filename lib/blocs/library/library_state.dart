import '../../models/song.dart';
import 'library_event.dart';

class LibraryState {
  final List<Song> songs;
  final List<Song> filteredSongs;
  final String searchQuery;
  final String? selectedFolder;
  final bool isLoading;
  final SortMode sortMode;

  const LibraryState({
    this.songs = const [],
    this.filteredSongs = const [],
    this.searchQuery = '',
    this.selectedFolder,
    this.isLoading = false,
    this.sortMode = SortMode.timeAddedAsc,
  });

  LibraryState copyWith({
    List<Song>? songs,
    List<Song>? filteredSongs,
    String? searchQuery,
    Object? selectedFolder = _noChange,
    bool? isLoading,
    SortMode? sortMode,
  }) {
    return LibraryState(
      songs: songs ?? this.songs,
      filteredSongs: filteredSongs ?? this.filteredSongs,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFolder: selectedFolder == _noChange
          ? this.selectedFolder
          : selectedFolder as String?,
      isLoading: isLoading ?? this.isLoading,
      sortMode: sortMode ?? this.sortMode,
    );
  }
}

const _noChange = Object();
