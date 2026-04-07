import '../entities/book.dart';
import '../entities/library.dart';

abstract class HomeRepository {
  Future<Book> getFeaturedBook();
  Future<Library?> getUserLibrary(String userId);
}
