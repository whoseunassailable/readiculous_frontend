import '../entities/library.dart';

abstract class LibraryRepository {
  /// Every library, sorted by name.
  Future<List<Library>> getAllLibraries();

  /// The user's home library, or null if they haven't picked one.
  Future<Library?> getUserLibrary(String userId);

  /// Makes [libraryId] a reader's home library (replaces any previous one).
  Future<void> setReaderLibrary(String userId, int libraryId);

  /// Assigns a librarian to [libraryId].
  Future<void> assignLibrarian(String userId, int libraryId);
}
