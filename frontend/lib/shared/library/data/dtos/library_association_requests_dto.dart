// Request bodies for joining a library.

/// A reader's home library (`POST /users/:id/library`).
class SetUserLibraryRequestDto {
  final int libraryId;
  const SetUserLibraryRequestDto({required this.libraryId});
  Map<String, dynamic> toJson() => {'library_id': libraryId};
}

/// A librarian's library (`POST /librarians/assign`). The app verifies the
/// assignment itself, as it always has.
class AssignLibrarianRequestDto {
  final String userId;
  final int libraryId;
  const AssignLibrarianRequestDto({
    required this.userId,
    required this.libraryId,
  });
  Map<String, dynamic> toJson() =>
      {'user_id': userId, 'library_id': libraryId, 'verified': 1};
}
