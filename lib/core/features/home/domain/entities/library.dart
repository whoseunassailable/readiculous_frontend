class Library {
  final int libraryId;
  final String name;
  final String? location;
  final int? verified; // from librarians. optional

  const Library({
    required this.libraryId,
    required this.name,
    this.location,
    this.verified,
  });
}
