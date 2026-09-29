import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/session/session_provider.dart';
import '../../domain/entities/user_recommendation.dart';
import 'recommendations_providers.dart';

/// The logged-in reader's saved picks. Shared by the dashboard and the
/// recommendations page; screens that change the reader's tastes (genre
/// preferences, finishing or rating a book) call [generate].
class UserRecommendationsNotifier
    extends AsyncNotifier<List<UserRecommendation>> {
  @override
  Future<List<UserRecommendation>> build() async {
    // Watch (not read) so another user logging in rebuilds this state.
    final userId = ref.watch(sessionProvider.select((s) => s.userId));
    if (userId == null) return [];
    return ref.read(getUserRecommendationsProvider).call(userId);
  }

  /// Re-reads the saved picks.
  Future<void> refresh() async {
    final userId = ref.read(sessionProvider).userId;
    if (userId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(getUserRecommendationsProvider).call(userId));
  }

  /// Runs the model with the reader's latest tastes, then loads the new picks.
  Future<void> generate({int topN = 10}) async {
    final userId = ref.read(sessionProvider).userId;
    if (userId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(generateUserRecommendationsProvider)
          .call(userId, topN: topN);
      return ref.read(getUserRecommendationsProvider).call(userId);
    });
  }
}

final userRecommendationsProvider = AsyncNotifierProvider<
    UserRecommendationsNotifier, List<UserRecommendation>>(
  UserRecommendationsNotifier.new,
);
