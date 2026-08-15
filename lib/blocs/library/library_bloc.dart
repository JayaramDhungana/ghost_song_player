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

    emit(
      state.copyWith(filteredSongs: filteredSongs, searchQuery: event.query),
    );
  }

  void _onFilterByFolder(FilterByFolder event, Emitter<LibraryState> emit) {
    final filteredSongs = _applyFilters(
      query: state.searchQuery,
      folder: event.folder,
    );

    emit(
      state.copyWith(
        filteredSongs: filteredSongs,
        selectedFolder: event.folder,
      ),
    );
  }
}
