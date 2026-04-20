import 'package:flutter_test/flutter_test.dart';
import 'package:readiculous_frontend/core/routing/routing.dart';
import 'package:readiculous_frontend/core/session/session_state.dart';

// Convenience constants used across multiple tests.
const _notInitialized = SessionState(initialized: false);
const _guest = SessionState(initialized: true);
const _userWithPrefs = SessionState(
  initialized: true,
  userId: 'u1',
  role: 'user',
  hasGenrePrefs: true,
);
const _userNoPrefs = SessionState(
  initialized: true,
  userId: 'u1',
  role: 'user',
  hasGenrePrefs: false,
);
const _librarian = SessionState(
  initialized: true,
  userId: 'lib1',
  role: 'librarian',
);

void main() {
  group('computeAuthRedirect', () {
    group('session not yet initialized', () {
      test('returns null at any route', () {
        expect(computeAuthRedirect(_notInitialized, '/'), isNull);
        expect(computeAuthRedirect(_notInitialized, '/home_page'), isNull);
        expect(computeAuthRedirect(_notInitialized, '/my_books'), isNull);
      });
    });

    group('unauthenticated (guest) user', () {
      test('stays on login page', () {
        expect(computeAuthRedirect(_guest, '/'), isNull);
      });

      test('stays on register page', () {
        expect(computeAuthRedirect(_guest, '/register_page'), isNull);
      });

      test('redirects to login from any protected route', () {
        for (final path in ['/home_page', '/my_books', '/view_database', '/profile_page']) {
          expect(
            computeAuthRedirect(_guest, path),
            '/',
            reason: 'Expected redirect to / from $path',
          );
        }
      });
    });

    group('authenticated user with genre preferences', () {
      test('redirects away from login page to home', () {
        expect(computeAuthRedirect(_userWithPrefs, '/'), '/home_page');
      });

      test('redirects away from register page to home', () {
        expect(computeAuthRedirect(_userWithPrefs, '/register_page'), '/home_page');
      });

      test('stays on home page', () {
        expect(computeAuthRedirect(_userWithPrefs, '/home_page'), isNull);
      });

      test('stays on other protected routes', () {
        expect(computeAuthRedirect(_userWithPrefs, '/my_books'), isNull);
        expect(computeAuthRedirect(_userWithPrefs, '/view_database'), isNull);
        expect(computeAuthRedirect(_userWithPrefs, '/profile_page'), isNull);
      });

      test('blocks revisiting the onboarding route', () {
        expect(computeAuthRedirect(_userWithPrefs, '/preferred_location'), '/home_page');
      });
    });

    group('authenticated user without genre preferences', () {
      test('is redirected from home to genre preferences onboarding', () {
        expect(computeAuthRedirect(_userNoPrefs, '/home_page'), '/preferred_location');
      });

      test('is redirected from any protected page to onboarding', () {
        expect(computeAuthRedirect(_userNoPrefs, '/my_books'), '/preferred_location');
        expect(computeAuthRedirect(_userNoPrefs, '/view_database'), '/preferred_location');
      });

      test('stays on the onboarding page', () {
        expect(computeAuthRedirect(_userNoPrefs, '/preferred_location'), isNull);
      });

      test('redirects away from login directly to onboarding (single hop)', () {
        // GoRouter 17+ calls redirect once per navigation, not per hop.
        // So from '/' we must jump directly to the final destination.
        expect(computeAuthRedirect(_userNoPrefs, '/'), '/preferred_location');
      });
    });

    group('librarian', () {
      test('redirects from login to home', () {
        expect(computeAuthRedirect(_librarian, '/'), '/home_page');
      });

      test('stays on home page', () {
        expect(computeAuthRedirect(_librarian, '/home_page'), isNull);
      });

      test('is NOT redirected to genre preferences onboarding', () {
        // Librarians skip the genre-prefs gate entirely
        expect(computeAuthRedirect(_librarian, '/home_page'), isNull);
        expect(computeAuthRedirect(_librarian, '/view_database'), isNull);
      });
    });
  });
}