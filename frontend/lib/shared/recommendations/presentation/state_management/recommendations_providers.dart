import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/session/session_provider.dart';
import '../../../library/presentation/state_management/library_providers.dart';
import '../../data/datasources/recommendations_remote_data_source.dart';
import '../../data/repositories/recommendations_repository_impl.dart';
import '../../domain/entities/library_recommendation.dart';
import '../../domain/repositories/recommendations_repository.dart';
import '../../domain/usecases/generate_library_recommendations.dart';
import '../../domain/usecases/generate_user_recommendations.dart';
import '../../domain/usecases/get_library_recommendations.dart';
import '../../domain/usecases/get_user_recommendations.dart';
import '../../domain/usecases/update_library_recommendation_state.dart';

final recommendationsRepositoryProvider = Provider<RecommendationsRepository>(
  (ref) => RecommendationsRepositoryImpl(RecommendationsRemoteDataSourceImpl()),
);

final getUserRecommendationsProvider = Provider<GetUserRecommendations>(
  (ref) => GetUserRecommendations(ref.watch(recommendationsRepositoryProvider)),
);

final generateUserRecommendationsProvider =
    Provider<GenerateUserRecommendations>(
  (ref) =>
      GenerateUserRecommendations(ref.watch(recommendationsRepositoryProvider)),
);

final getLibraryRecommendationsProvider = Provider<GetLibraryRecommendations>(
  (ref) =>
      GetLibraryRecommendations(ref.watch(recommendationsRepositoryProvider)),
);

final generateLibraryRecommendationsProvider =
    Provider<GenerateLibraryRecommendations>(
  (ref) => GenerateLibraryRecommendations(
      ref.watch(recommendationsRepositoryProvider)),
);

final updateLibraryRecommendationStateProvider =
    Provider<UpdateLibraryRecommendationState>(
  (ref) => UpdateLibraryRecommendationState(
      ref.watch(recommendationsRepositoryProvider)),
);

/// Saved stocking recommendations for a library. Invalidate the whole family
/// (`ref.invalidate(libraryRecommendationsProvider)`) after changing them.
final libraryRecommendationsProvider =
    FutureProvider.autoDispose.family<List<LibraryRecommendation>, int>(
  (ref, libraryId) =>
      ref.watch(getLibraryRecommendationsProvider).call(libraryId),
);

/// Recommendations for the logged-in librarian's library (empty without one).
final currentLibraryRecommendationsProvider =
    FutureProvider.autoDispose<List<LibraryRecommendation>>(
  (ref) async {
    final userId = ref.watch(sessionProvider.select((s) => s.userId));
    if (userId == null) return [];

    final library = await ref.watch(userLibraryProvider(userId).future);
    if (library == null) return [];

    return ref.watch(libraryRecommendationsProvider(library.libraryId).future);
  },
);
