enum SortMode {
  timeAddedAsc,   // Original order (oldest first)
  timeAddedDesc,  // Reverse order (newest first)
  alphabeticalAsc,  // A → Z
  alphabeticalDesc, // Z → A
}

sealed class LibraryEvent {
  const LibraryEvent();
}

class LoadLibrary extends LibraryEvent {
  const LoadLibrary();
}

class SearchSongs extends LibraryEvent {
  final String query;

  const SearchSongs(this.query);
}

class FilterByFolder extends LibraryEvent {
  final String? folder;

  const FilterByFolder(this.folder);
}

class SortSongs extends LibraryEvent {
  final SortMode sortMode;

  const SortSongs(this.sortMode);
}