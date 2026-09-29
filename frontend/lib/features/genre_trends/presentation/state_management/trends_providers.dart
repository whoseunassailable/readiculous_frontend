import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/session/session_provider.dart';
import '../../../../shared/library/presentation/state_management/library_providers.dart';
import '../../data/datasources/trends_remote_data_source.dart';
import '../../data/repositories/trends_repository_impl.dart';
import '../../domain/entities/genre_trend.dart';
import '../../domain/repositories/trends_repository.dart';
import '../../domain/usecases/get_top_trends.dart';

final trendsRepositoryProvider = Provider<TrendsRepository>(
  (ref) => TrendsRepositoryImpl(TrendsRemoteDataSourceImpl()),
);

final getTopTrendsProvider = Provider<GetTopTrends>(
  (ref) => GetTopTrends(ref.watch(trendsRepositoryProvider)),
);

/// Genre trends for the logged-in librarian's library, highest first. Empty
/// when there is no user or no library.
final genreTrendsProvider = FutureProvider.autoDispose<List<GenreTrend>>(
  (ref) async {
    final userId = ref.watch(sessionProvider.select((s) => s.userId));
    if (userId == null) return [];

    final library = await ref.watch(userLibraryProvider(userId).future);
    if (library == null) return [];

    return ref.watch(getTopTrendsProvider).call(library.libraryId);
  },
);
