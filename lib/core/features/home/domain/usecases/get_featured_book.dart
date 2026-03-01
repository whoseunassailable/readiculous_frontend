import '../entities/book.dart';
import '../repositories/home_repository.dart';
import '../entities/library.dart';

class GetFeaturedBook {
  final HomeRepository repo;

  const GetFeaturedBook(this.repo);

  Future<Book> call() => repo.getFeaturedBook();
}
