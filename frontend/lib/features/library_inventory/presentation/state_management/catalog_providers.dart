import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/catalog_remote_data_source.dart';
import '../../data/repositories/catalog_repository_impl.dart';
import '../../domain/entities/catalog_book.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/usecases/search_catalog.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepositoryImpl(CatalogRemoteDataSourceImpl()),
);

final searchCatalogProvider = Provider<SearchCatalog>(
  (ref) => SearchCatalog(ref.watch(catalogRepositoryProvider)),
);

/// Catalog books matching [query] by title or author. Nothing is fetched
/// for fewer than [minCatalogQueryLength] characters.
final catalogSearchProvider =
    FutureProvider.autoDispose.family<List<CatalogBook>, String>(
  (ref, query) async {
    final q = query.trim();
    if (q.length < minCatalogQueryLength) return const [];
    return ref.watch(searchCatalogProvider).call(q);
  },
);

const minCatalogQueryLength = 2;
