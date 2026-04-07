import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/network/clients/user_genres_api_client.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';

class GenrePreferencesNotifier
    extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final userId = ref.read(sessionProvider).userId;
    if (userId == null) return [];

    final raw = await UserGenresApiClient(DioClient.main)
        .getUserGenrePreferences(userId);
    return raw.cast<Map<String, dynamic>>();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<void> replaceSelections({
    required String userId,
    required Set<String> currentGenreIds,
    required Set<String> nextGenreIds,
  }) async {
    final toRemove = currentGenreIds.difference(nextGenreIds);
    final toAdd = nextGenreIds.difference(currentGenreIds);
    final client = UserGenresApiClient(DioClient.main);

    for (final genreId in toRemove) {
      await client.removeUserGenrePreference(userId, genreId);
    }

    if (toAdd.isNotEmpty) {
      await client.addUserGenrePreferences({
        'user_id': userId,
        'genre_ids': toAdd.toList(),
      });
    }

    await ref.read(sessionProvider.notifier).markGenrePrefsSet();
    await refresh();
  }
}

final genrePreferencesProvider =
    AsyncNotifierProvider<GenrePreferencesNotifier, List<Map<String, dynamic>>>(
  GenrePreferencesNotifier.new,
);
