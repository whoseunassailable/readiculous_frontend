import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';

// Not autoDispose — results are cached for the session lifetime.
// Invalidate explicitly when genre preferences change.
class UserRecommendationsController extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    final userId = ref.read(sessionProvider).userId;
    if (userId == null) throw Exception('Not logged in');

    // Single call to Node backend — it fetches genres, calls Flask internally,
    // resolves books against the DB, and returns full book details.
    final resp = await DioClient.main.post<dynamic>(
      '/recommendations/users/$userId/generate',
      data: {'top_n': 10},
    );

    final data = resp.data as Map<String, dynamic>?;
    return (data?['recommendations'] as List<dynamic>?) ?? [];
  }
}

final userRecommendationsProvider =
    AsyncNotifierProvider<UserRecommendationsController, List<dynamic>>(
  UserRecommendationsController.new,
);