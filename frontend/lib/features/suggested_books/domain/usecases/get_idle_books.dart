import '../entities/idle_book.dart';
import '../repositories/shelf_repository.dart';

class GetIdleBooks {
  final ShelfRepository repo;

  const GetIdleBooks(this.repo);

  Future<IdleShelf> call(int libraryId) => repo.getIdleBooks(libraryId);
}
