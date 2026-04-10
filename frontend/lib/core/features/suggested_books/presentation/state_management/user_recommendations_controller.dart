import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/network/clients/user_genres_api_client.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';

// Not autoDispose — results are cached for the session lifetime.
// The provider is invalidated explicitly when genre preferences change.
class UserRecommendationsController extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    final userId = ref.read(sessionProvider).userId;
    if (userId == null) throw Exception('Not logged in');

    // Step 1: get user's genre preferences from Node
    final genres = await UserGenresApiClient(DioClient.main)
        .getUserGenrePreferences(userId);
    final genreNames = genres
        .cast<Map<String, dynamic>>()
        .map((g) => g['name']?.toString() ?? '')
        .toList();

    if (genreNames.isEmpty) return [];

    // Step 2: get book recommendations from Flask ML model
    // Passing user_id enables the hybrid CF layer on the ML side;
    // the service falls back to content-only if CF isn't trained yet.
    final resp = await DioClient.flask.post<dynamic>(
      '/recommend',
      data: {'genres': genreNames, 'user_id': userId, 'top_n': 10},
    );
    return (resp.data as List<dynamic>?) ?? [];
  }
}

final userRecommendationsProvider =
    AsyncNotifierProvider<UserRecommendationsController, List<dynamic>>(
  UserRecommendationsController.new,
);
