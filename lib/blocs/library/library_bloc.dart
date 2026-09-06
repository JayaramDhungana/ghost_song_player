import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/song.dart';
import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc({required List<Song> songs})
    : super(LibraryState(songs: songs, filteredSongs: songs)) {
    on<LoadLibrary>(_onLoadLibrary);
    on<SearchSongs>(_onSearchSongs);
    on<FilterByFolder>(_onFilterByFolder);
    on<SortSongs>(_onSortSongs);
  }

  List<Song> _applyFilters({required String query, required String? folder}) {
    final normalizedQuery = query.trim().toLowerCase();

    return state.songs.where((song) {
      final matchesFolder =
    folder == null || song.folders.contains(folder);

      if (!matchesFolder) {
        return false;
      }

      if (normalizedQuery.isEmpty) {
        return true;
      }

      final title = song.title.toLowerCase();
      final artist = (song.artist ?? '').toLowerCase();

      return title.contains(normalizedQuery) ||
          artist.contains(normalizedQuery);
    }).toList();
  }

  List<Song> _applySorting(List<Song> songs, SortMode sortMode) {
    final sorted = List<Song>.from(songs);

    switch (sortMode) {
      case SortMode.timeAddedAsc:
        // Original order — use the index from the master list
        sorted.sort((a, b) {
          final aIndex = state.songs.indexOf(a);
          final bIndex = state.songs.indexOf(b);
          return aIndex.compareTo(bIndex);
        });
      case SortMode.timeAddedDesc:
        // Reverse of original order
        sorted.sort((a, b) {
          final aIndex = state.songs.indexOf(a);
          final bIndex = state.songs.indexOf(b);
          return bIndex.compareTo(aIndex);
        });
      case SortMode.alphabeticalAsc:
        // A → Z
        sorted.sort((a, b) =>
            a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case SortMode.alphabeticalDesc:
        // Z → A
        sorted.sort((a, b) =>
            b.title.toLowerCase().compareTo(a.title.toLowerCase()));
    }

    return sorted;
  }

  void _onLoadLibrary(LoadLibrary event, Emitter<LibraryState> emit) {
    emit(
      state.copyWith(
        songs: state.songs,
        filteredSongs: state.songs,
        searchQuery: '',
        isLoading: false,
      ),
    );
  }

  void _onSearchSongs(SearchSongs event, Emitter<LibraryState> emit) {
    final filteredSongs = _applyFilters(
      query: event.query,
      folder: state.selectedFolder,
    );

    final sortedSongs = _applySorting(filteredSongs, state.sortMode);

    emit(
      state.copyWith(filteredSongs: sortedSongs, searchQuery: event.query),
    );
  }

  void _onFilterByFolder(FilterByFolder event, Emitter<LibraryState> emit) {
    final filteredSongs = _applyFilters(
      query: state.searchQuery,
      folder: event.folder,
    );

    final sortedSongs = _applySorting(filteredSongs, state.sortMode);

    emit(
      state.copyWith(
        filteredSongs: sortedSongs,
        selectedFolder: event.folder,
      ),
    );
  }

  void _onSortSongs(SortSongs event, Emitter<LibraryState> emit) {
    final filteredSongs = _applyFilters(
      query: state.searchQuery,
      folder: state.selectedFolder,
    );

    final sortedSongs = _applySorting(filteredSongs, event.sortMode);

    emit(
      state.copyWith(
        filteredSongs: sortedSongs,
        sortMode: event.sortMode,
      ),
    );
  }
}
