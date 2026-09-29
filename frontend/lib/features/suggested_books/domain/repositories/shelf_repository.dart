import '../entities/idle_book.dart';

abstract class ShelfRepository {
  Future<IdleShelf> getIdleBooks(int libraryId);

  /// Takes [copies] of a book off the library's shelf.
  Future<void> removeCopies(int libraryId, int bookId, int copies);
}
