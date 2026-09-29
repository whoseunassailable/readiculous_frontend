import '../repositories/library_repository.dart';

/// Joins a library. Readers and librarians are linked to libraries through
/// different records (the backend refuses a librarian as a reader).
///
/// A reader can switch libraries at any time. A librarian owns one library:
/// their first choice is final, and the backend refuses a different one.
class ChooseLibrary {
  final LibraryRepository repo;

  const ChooseLibrary(this.repo);

  Future<void> call(
    String userId,
    int libraryId, {
    required bool asLibrarian,
  }) =>
      asLibrarian
          ? repo.assignLibrarian(userId, libraryId)
          : repo.setReaderLibrary(userId, libraryId);
}
