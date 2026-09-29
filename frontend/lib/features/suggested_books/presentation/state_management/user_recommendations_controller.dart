import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/network/clients/recommendations_api_client.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';

class UserRecommendationsController extends AsyncNotifier<List<dynamic>> {
  String? _userId() => ref.read(sessionProvider).userId;

  Future<List<dynamic>> _fetchSavedRecommendations(String userId) {
    return RecommendationsApiClient(DioClient.main)
        .getUserRecommendations(userId);
  }

  @override
  Future<List<dynamic>> build() async {
    final userId = _userId();
    if (userId == null) throw Exception('Not logged in');
    return _fetchSavedRecommendations(userId);
  }

  Future<void> refresh() async {
    final userId = _userId();
    if (userId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchSavedRecommendations(userId));
  }

  Future<void> generate({int topN = 10}) async {
    final userId = _userId();
    if (userId == null) return;
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(() async {
      final resp = await DioClient.main.post<dynamic>(
        '/recommendations/users/$userId/generate',
        data: {'top_n': topN},
      );
      final data = resp.data as Map<String, dynamic>?;
      final generated = (data?['recommendations'] as List<dynamic>?) ?? [];
      if (generated.isNotEmpty) {
        return _fetchSavedRecommendations(userId);
      }
      return _fetchSavedRecommendations(userId);
    });
    state = nextState;
  }
}

final userRecommendationsProvider =
    AsyncNotifierProvider<UserRecommendationsController, List<dynamic>>(
  UserRecommendationsController.new,
);
