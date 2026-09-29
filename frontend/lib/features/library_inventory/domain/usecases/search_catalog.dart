import '../entities/catalog_book.dart';
import '../repositories/catalog_repository.dart';

class SearchCatalog {
  final CatalogRepository repo;

  const SearchCatalog(this.repo);

  Future<List<CatalogBook>> call(String query) => repo.searchBooks(query);
}
