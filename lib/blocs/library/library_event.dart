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