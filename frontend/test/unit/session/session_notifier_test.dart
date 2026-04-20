import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/core/session/session_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SessionNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('starts uninitialized with all fields null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final s = container.read(sessionProvider);
      expect(s.initialized, false);
      expect(s.userId, isNull);
      expect(s.role, isNull);
      expect(s.email, isNull);
      expect(s.token, isNull);
      expect(s.hasGenrePrefs, isNull);
    });

    test('init with no persisted data produces empty initialized session', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sessionProvider.notifier).init();

      final s = container.read(sessionProvider);
      expect(s.initialized, true);
      expect(s.userId, isNull);
      expect(s.role, isNull);
    });

    test('init loads a persisted user session', () async {
      SharedPreferences.setMockInitialValues({
        'user_id': 'u42',
        'role': 'user',
        'email': 'reader@readiculous.com',
        'token': 'tok_abc',
        'has_genre_prefs': true,
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sessionProvider.notifier).init();

      final s = container.read(sessionProvider);
      expect(s.userId, 'u42');
      expect(s.role, 'user');
      expect(s.email, 'reader@readiculous.com');
      expect(s.token, 'tok_abc');
      expect(s.hasGenrePrefs, true);
      expect(s.initialized, true);
    });

    test('init loads a persisted librarian session', () async {
      SharedPreferences.setMockInitialValues({
        'user_id': 'lib1',
        'role': 'librarian',
        'email': 'lib@lib.com',
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sessionProvider.notifier).init();

      final s = container.read(sessionProvider);
      expect(s.userId, 'lib1');
      expect(s.role, 'librarian');
    });

    test('setSession updates in-memory state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sessionProvider.notifier).setSession(
        userId: 'u99',
        role: 'user',
        email: 'x@x.com',
        token: 'tok_xyz',
      );

      final s = container.read(sessionProvider);
      expect(s.userId, 'u99');
      expect(s.role, 'user');
      expect(s.email, 'x@x.com');
      expect(s.token, 'tok_xyz');
    });

    test('setSession persists to SharedPreferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sessionProvider.notifier).setSession(
        userId: 'u99',
        role: 'user',
        email: 'x@x.com',
        token: 'tok_xyz',
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_id'), 'u99');
      expect(prefs.getString('role'), 'user');
      expect(prefs.getString('email'), 'x@x.com');
      expect(prefs.getString('token'), 'tok_xyz');
    });

    test('clearSession wipes in-memory state but stays initialized', () async {
      SharedPreferences.setMockInitialValues({
        'user_id': 'u1',
        'role': 'user',
        'email': 'a@b.com',
        'token': 'tok',
        'has_genre_prefs': true,
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sessionProvider.notifier).init();
      await container.read(sessionProvider.notifier).clearSession();

      final s = container.read(sessionProvider);
      expect(s.userId, isNull);
      expect(s.role, isNull);
      expect(s.email, isNull);
      expect(s.token, isNull);
      expect(s.hasGenrePrefs, isNull);
      expect(s.initialized, true); // stays true after logout
    });

    test('clearSession removes all keys from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'user_id': 'u1',
        'role': 'user',
        'has_genre_prefs': true,
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sessionProvider.notifier).init();
      await container.read(sessionProvider.notifier).clearSession();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_id'), isNull);
      expect(prefs.getString('role'), isNull);
      expect(prefs.getBool('has_genre_prefs'), isNull);
    });

    test('markGenrePrefsSet sets hasGenrePrefs to true', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sessionProvider.notifier).markGenrePrefsSet();

      expect(container.read(sessionProvider).hasGenrePrefs, true);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_genre_prefs'), true);
    });

    test('setGenrePrefsStatus false clears the genre flag', () async {
      SharedPreferences.setMockInitialValues({'has_genre_prefs': true});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sessionProvider.notifier).init();
      await container.read(sessionProvider.notifier).setGenrePrefsStatus(false);

      expect(container.read(sessionProvider).hasGenrePrefs, false);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_genre_prefs'), false);
    });

    test('SessionState.copyWith preserves unchanged fields', () {
      const original = SessionState(
        userId: 'u1',
        role: 'user',
        email: 'a@b.com',
        token: 'tok',
        initialized: true,
        hasGenrePrefs: false,
      );

      final updated = original.copyWith(role: 'librarian');

      expect(updated.userId, 'u1');
      expect(updated.role, 'librarian');
      expect(updated.email, 'a@b.com');
      expect(updated.token, 'tok');
      expect(updated.initialized, true);
      expect(updated.hasGenrePrefs, false);
    });
  });
}
