import '../repositories/shelf_repository.dart';

class RemoveCopies {
  final ShelfRepository repo;

  const RemoveCopies(this.repo);

  Future<void> call(int libraryId, int bookId, int copies) =>
      repo.removeCopies(libraryId, bookId, copies);
}
