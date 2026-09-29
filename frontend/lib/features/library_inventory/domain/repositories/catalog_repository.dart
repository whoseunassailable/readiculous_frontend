import '../entities/catalog_book.dart';

abstract class CatalogRepository {
  /// Up to [limit] catalog books whose title or author contains [query],
  /// in title order. The catalog is ~85k books, so it is searched on the
  /// server rather than downloaded.
  Future<List<CatalogBook>> searchBooks(String query, {int limit = 20});
}
