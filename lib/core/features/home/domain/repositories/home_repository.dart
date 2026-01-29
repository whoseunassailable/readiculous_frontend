import '../entities/book.dart';

abstract class HomeRepository {
  Future<Book> getFeaturedBook();
}
