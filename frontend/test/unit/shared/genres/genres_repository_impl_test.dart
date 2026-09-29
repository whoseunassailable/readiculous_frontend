import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readiculous_frontend/core/network/api_error.dart';
import 'package:readiculous_frontend/core/session/session_notifier.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/core/session/session_state.dart';
import 'package:readiculous_frontend/shared/genres/data/datasources/genres_remote_data_source.dart';
import 'package:readiculous_frontend/shared/genres/data/dtos/add_user_genres_request_dto.dart';
import 'package:readiculous_frontend/shared/genres/data/dtos/genre_dto.dart';
import 'package:readiculous_frontend/shared/genres/data/repositories/genres_repository_impl.dart';
import 'package:readiculous_frontend/shared/genres/domain/entities/genre.dart';
import 'package:readiculous_frontend/shared/genres/domain/repositories/genres_repository.dart';
import 'package:readiculous_frontend/shared/genres/domain/usecases/save_user_genres.dart';
import 'package:readiculous_frontend/shared/genres/presentation/state_management/genres_providers.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

class _FakeRemote implements GenresRemoteDataSource {
  List<GenreDto> genres = [];
  Object? error;
  final added = <(String, List<int>)>[];
  final removed = <(String, int)>[];

  @override
  Future<List<GenreDto>> fetchAllGenres() async {
    if (error != null) throw error!;
    return genres;
  }

  @override
  Future<List<GenreDto>> fetchUserGenres(String userId) async {
    if (error != null) throw error!;
    return genres;
  }

  @override
  Future<void> addUserGenres(String userId, List<int> genreIds) async {
    if (error != null) throw error!;
    added.add((userId, genreIds));
  }

  @override
  Future<void> removeUserGenre(String userId, int genreId) async {
    if (error != null) throw error!;
    removed.add((userId, genreId));
  }
}

/// A user's genres as the server holds them; add/remove change that state.
class _FakeRepository implements GenresRepository {
  Set<int> saved;
  final calls = <String>[];
  _FakeRepository(this.saved);

  @override
  Future<List<Genre>> getAllGenres() async => [];

  @override
  Future<List<Genre>> getUserGenres(String userId) async =>
      [for (final id in saved) Genre(genreId: id, name: 'g$id')];

  @override
  Future<void> addUserGenres(String userId, List<int> genreIds) async {
    calls.add('add ${(genreIds.toList()..sort()).join(',')}');
    saved.addAll(genreIds);
  }

  @override
  Future<void> removeUserGenre(String userId, int genreId) async {
    calls.add('remove $genreId');
    saved.remove(genreId);
  }
}

class _FixedSession extends SessionNotifier {
  final SessionState _state;
  _FixedSession(this._state);

  @override
  SessionState build() => _state;
}

DioException _serverError(int status, String message) {
  final options = RequestOptions(path: '/user-genres/u1');
  return DioException(
    requestOptions: options,
    response: Response(
        requestOptions: options,
        statusCode: status,
        data: {'message': message}),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  test('GenreDto parses GET /user-genres/:id rows', () {
    final genre =
        GenreDto.fromJson({'genre_id': 7, 'name': 'Fantasy'}).toEntity();
    expect(genre.genreId, 7);
    expect(genre.name, 'Fantasy');
  });

  test('AddUserGenresRequestDto matches POST /user-genres', () {
    expect(
      const AddUserGenresRequestDto(userId: 'u1', genreIds: [1, 2]).toJson(),
      {
        'user_id': 'u1',
        'genre_ids': [1, 2]
      },
    );
  });

  group('GenresRepositoryImpl', () {
    test('getUserGenres maps DTOs to entities', () async {
      final remote = _FakeRemote()
        ..genres = const [
          GenreDto(genreId: 1, name: 'Fantasy'),
          GenreDto(genreId: 2, name: 'Mystery'),
        ];

      final genres = await GenresRepositoryImpl(remote).getUserGenres('u1');

      expect(genres.map((g) => g.name), ['Fantasy', 'Mystery']);
    });

    test('getAllGenres maps the whole catalog (GET /genres)', () async {
      final remote = _FakeRemote()
        ..genres = const [
          GenreDto(genreId: 1, name: 'Action'),
          GenreDto(genreId: 2, name: 'Adventure'),
        ];

      final genres = await GenresRepositoryImpl(remote).getAllGenres();

      expect(genres.map((g) => g.genreId), [1, 2]);
    });

    test('addUserGenres and removeUserGenre reach the data source', () async {
      final remote = _FakeRemote();
      final repo = GenresRepositoryImpl(remote);

      await repo.addUserGenres('u1', [3, 4]);
      await repo.removeUserGenre('u1', 5);

      expect(remote.added.single.$1, 'u1');
      expect(remote.added.single.$2, [3, 4]);
      expect(remote.removed.single, ('u1', 5));
    });

    test('server errors become an ApiError with the backend message', () async {
      final remote = _FakeRemote()
        ..error = _serverError(404, 'Preference not found');

      await expectLater(
        GenresRepositoryImpl(remote).removeUserGenre('u1', 9),
        throwsA(isA<ApiError>()
            .having((e) => e.message, 'message', 'Preference not found')),
      );
    });
  });

  group('SaveUserGenres', () {
    test('removes deselected genres and adds new ones', () async {
      final repo = _FakeRepository({1, 2, 3});

      await SaveUserGenres(repo).call('u1', {2, 3, 4, 5});

      expect(repo.calls, ['remove 1', 'add 4,5']);
      expect(repo.saved, {2, 3, 4, 5});
    });

    test('onboarding: nothing saved yet ⇒ one add, no removes', () async {
      final repo = _FakeRepository({});

      await SaveUserGenres(repo).call('u1', {7, 8});

      expect(repo.calls, ['add 7,8']);
    });

    test('unchanged selection ⇒ no requests', () async {
      final repo = _FakeRepository({1, 2});

      await SaveUserGenres(repo).call('u1', {1, 2});

      expect(repo.calls, isEmpty);
    });

    test('diffs against the server, not a stale screen', () async {
      // The screen thought the user had {1}, but another device added 2.
      final repo = _FakeRepository({1, 2});

      await SaveUserGenres(repo).call('u1', {1, 3});

      expect(repo.calls, ['remove 2', 'add 3']);
    });
  });

  group('userGenresProvider', () {
    ProviderContainer container(String? userId, Set<int> saved) {
      final c = ProviderContainer(overrides: [
        sessionProvider.overrideWith(() => _FixedSession(
            SessionState(initialized: true, userId: userId, role: 'user'))),
        genresRepositoryProvider.overrideWithValue(_FakeRepository(saved)),
      ]);
      addTearDown(c.dispose);
      return c;
    }

    test('logged out ⇒ empty', () async {
      expect(
          await container(null, {1}).read(userGenresProvider.future), isEmpty);
    });

    test("loads the logged-in user's genres", () async {
      final genres =
          await container('u1', {1, 2}).read(userGenresProvider.future);
      expect(genres.map((g) => g.genreId).toSet(), {1, 2});
    });
  });
}
