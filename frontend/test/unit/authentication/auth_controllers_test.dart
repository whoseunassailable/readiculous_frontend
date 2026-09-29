import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readiculous_frontend/core/network/api_error.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/features/authentication/domain/entities/user.dart';
import 'package:readiculous_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:readiculous_frontend/features/authentication/presentation/state_management/auth_providers.dart';
import 'package:readiculous_frontend/features/authentication/presentation/state_management/login_controller.dart';
import 'package:readiculous_frontend/features/authentication/presentation/state_management/register_controller.dart';
import 'package:readiculous_frontend/shared/genres/domain/entities/genre.dart';
import 'package:readiculous_frontend/shared/genres/domain/repositories/genres_repository.dart';
import 'package:readiculous_frontend/shared/genres/presentation/state_management/genres_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

class _FakeAuthRepository implements AuthRepository {
  User user;
  ApiError? error;
  _FakeAuthRepository(this.user);

  @override
  Future<User> login({required String email, required String password}) async {
    if (error != null) throw error!;
    return user;
  }

  @override
  Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String dateOfBirth,
    required String password,
    required String location,
    required String role,
  }) async {
    if (error != null) throw error!;
    return user;
  }
}

class _FakeGenresRepository implements GenresRepository {
  List<Genre> genres;
  bool fail = false;
  int calls = 0;
  _FakeGenresRepository(this.genres);

  @override
  Future<List<Genre>> getUserGenres(String userId) async {
    calls++;
    if (fail) throw const ApiError(message: 'boom');
    return genres;
  }
}

const _reader = User(
  userId: 'u1',
  firstName: 'Ada',
  lastName: 'Lovelace',
  email: 'ada@example.com',
  role: 'user',
);

const _librarian = User(
  userId: 'lib1',
  firstName: 'Lib',
  lastName: 'Rarian',
  email: 'lib@example.com',
  role: 'librarian',
);

ProviderContainer _container(
  _FakeAuthRepository auth,
  _FakeGenresRepository genres,
) {
  final container = ProviderContainer(overrides: [
    authRepositoryProvider.overrideWithValue(auth),
    genresRepositoryProvider.overrideWithValue(genres),
  ]);
  addTearDown(container.dispose);
  // The controllers are autoDispose — keep them alive for the test.
  container.listen(loginControllerProvider, (_, __) {});
  container.listen(registerControllerProvider, (_, __) {});
  return container;
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // Blocks real network calls: the post-login cache warm-up hits the API
  // and must not reach a real server from a unit test.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('LoginController', () {
    test('reader with genre prefs → session saved with hasGenrePrefs=true',
        () async {
      final c = _container(
        _FakeAuthRepository(_reader),
        _FakeGenresRepository([const Genre(genreId: 1, name: 'Fantasy')]),
      );

      await c
          .read(loginControllerProvider.notifier)
          .login(email: 'ada@example.com', password: 'pw');

      final session = c.read(sessionProvider);
      expect(session.userId, 'u1');
      expect(session.role, 'user');
      expect(session.email, 'ada@example.com');
      expect(session.hasGenrePrefs, true);
      expect(c.read(loginControllerProvider), isA<AsyncData<void>>());
    });

    test('reader without genre prefs → hasGenrePrefs=false (onboarding)',
        () async {
      final c = _container(
        _FakeAuthRepository(_reader),
        _FakeGenresRepository([]),
      );

      await c
          .read(loginControllerProvider.notifier)
          .login(email: 'ada@example.com', password: 'pw');

      expect(c.read(sessionProvider).hasGenrePrefs, false);
    });

    test('genre lookup failure does not block login', () async {
      final genres = _FakeGenresRepository([])..fail = true;
      final c = _container(_FakeAuthRepository(_reader), genres);

      await c
          .read(loginControllerProvider.notifier)
          .login(email: 'ada@example.com', password: 'pw');

      expect(c.read(sessionProvider).userId, 'u1');
      expect(c.read(sessionProvider).hasGenrePrefs, false);
      expect(c.read(loginControllerProvider), isA<AsyncData<void>>());
    });

    test('librarian skips the genre lookup', () async {
      final genres = _FakeGenresRepository([]);
      final c = _container(_FakeAuthRepository(_librarian), genres);

      await c
          .read(loginControllerProvider.notifier)
          .login(email: 'lib@example.com', password: 'pw');

      expect(genres.calls, 0);
      expect(c.read(sessionProvider).role, 'librarian');
    });

    test('failed login → AsyncError carrying the ApiError, no session',
        () async {
      final auth = _FakeAuthRepository(_reader)
        ..error =
            const ApiError(statusCode: 401, message: 'Invalid credentials');
      final c = _container(auth, _FakeGenresRepository([]));

      await c
          .read(loginControllerProvider.notifier)
          .login(email: 'ada@example.com', password: 'wrong');

      final state = c.read(loginControllerProvider);
      expect(state.hasError, true);
      expect(state.error.toString(), 'Invalid credentials');
      expect(c.read(sessionProvider).userId, isNull);
    });
  });

  group('RegisterController', () {
    Future<void> register(ProviderContainer c) =>
        c.read(registerControllerProvider.notifier).register(
              firstName: 'Ada',
              lastName: 'Lovelace',
              email: 'ada@example.com',
              phone: '5551234567',
              dateOfBirth: '1990-01-01',
              password: 'Secret@123',
              location: 'London',
              role: 'user',
            );

    test('success → session saved from the created user', () async {
      final c = _container(
        _FakeAuthRepository(_reader),
        _FakeGenresRepository([]),
      );

      await register(c);

      final session = c.read(sessionProvider);
      expect(session.userId, 'u1');
      expect(session.role, 'user');
      expect(session.email, 'ada@example.com');
      expect(c.read(registerControllerProvider), isA<AsyncData<void>>());
    });

    test('failure → AsyncError, no session', () async {
      final auth = _FakeAuthRepository(_reader)
        ..error =
            const ApiError(statusCode: 409, message: 'Email already exists');
      final c = _container(auth, _FakeGenresRepository([]));

      await register(c);

      final state = c.read(registerControllerProvider);
      expect(state.error.toString(), 'Email already exists');
      expect(c.read(sessionProvider).userId, isNull);
    });
  });
}
