import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readiculous_frontend/core/network/api_error.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/features/genre_preferences/presentation/state_management/genre_preferences_controller.dart';
import 'package:readiculous_frontend/shared/genres/domain/entities/genre.dart';
import 'package:readiculous_frontend/shared/genres/domain/repositories/genres_repository.dart';
import 'package:readiculous_frontend/shared/genres/presentation/state_management/genres_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepository implements GenresRepository {
  Set<int> saved = {};
  ApiError? error;
  int reads = 0;

  @override
  Future<List<Genre>> getAllGenres() async => [];

  @override
  Future<List<Genre>> getUserGenres(String userId) async {
    reads++;
    return [for (final id in saved) Genre(genreId: id, name: 'g$id')];
  }

  @override
  Future<void> addUserGenres(String userId, List<int> genreIds) async {
    if (error != null) throw error!;
    saved.addAll(genreIds);
  }

  @override
  Future<void> removeUserGenre(String userId, int genreId) async {
    saved.remove(genreId);
  }
}

Future<(ProviderContainer, _FakeRepository)> _newReader() async {
  SharedPreferences.setMockInitialValues({});
  final repo = _FakeRepository();
  final c = ProviderContainer(
      overrides: [genresRepositoryProvider.overrideWithValue(repo)]);
  addTearDown(c.dispose);
  await c
      .read(sessionProvider.notifier)
      .setSession(userId: 'u1', role: 'user', hasGenrePrefs: false);
  c.listen(genrePreferencesControllerProvider, (_, __) {});
  return (c, repo);
}

void main() {
  test('saves the genres and unlocks the app', () async {
    final (c, repo) = await _newReader();

    await c.read(genrePreferencesControllerProvider.notifier).save({3, 5});

    expect(repo.saved, {3, 5});
    expect(c.read(sessionProvider).hasGenrePrefs, true);
    expect(c.read(genrePreferencesControllerProvider), isA<AsyncData<void>>());
  });

  test('refreshes the saved genres other screens show', () async {
    final (c, repo) = await _newReader();
    c.listen(userGenresProvider, (_, __) {});
    expect(await c.read(userGenresProvider.future), isEmpty);

    await c.read(genrePreferencesControllerProvider.notifier).save({3});

    final genres = await c.read(userGenresProvider.future);
    expect(genres.map((g) => g.genreId), [3]);
  });

  test('failure ⇒ AsyncError and onboarding stays locked', () async {
    final (c, repo) = await _newReader();
    repo.error =
        const ApiError(statusCode: 500, message: 'Internal server error');

    await c.read(genrePreferencesControllerProvider.notifier).save({3});

    expect(c.read(genrePreferencesControllerProvider).error.toString(),
        'Internal server error');
    expect(c.read(sessionProvider).hasGenrePrefs, false);
  });
}
