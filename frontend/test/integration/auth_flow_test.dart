/// Integration tests: full auth routing flow using the real GoRouter + real
/// redirect logic. Each test pumps a lightweight TestApp that builds the router
/// from a ConsumerStatefulWidget (mirrors _MyAppState in main.dart) and uses
/// ProviderScope overrides to inject a fixed session state without hitting
/// SharedPreferences or any network API.
///
/// We also override every data-fetching provider referenced by the landing
/// pages (HomePage, PreferredGenre) with stubs that return empty data
/// immediately, so pages render without a backend.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/core/features/authentication/presentation/pages/login_page.dart';
import 'package:readiculous_frontend/core/features/home/presentation/pages/home_page.dart';
import 'package:readiculous_frontend/core/features/home/presentation/state_management/genres_provider.dart';
import 'package:readiculous_frontend/core/features/home/presentation/state_management/library_recommendations_provider.dart';
import 'package:readiculous_frontend/core/features/home/presentation/state_management/user_library_provider.dart';
import 'package:readiculous_frontend/core/features/my_books/presentation/state_management/my_books_provider.dart';
import 'package:readiculous_frontend/core/features/suggested_books/presentation/preferred_genre.dart';
import 'package:readiculous_frontend/core/features/suggested_books/presentation/state_management/user_recommendations_controller.dart';
import 'package:readiculous_frontend/core/routing/routing.dart';
import 'package:readiculous_frontend/core/session/session_notifier.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/core/session/session_state.dart';
import 'package:readiculous_frontend/generated/l10n.dart';
import 'package:readiculous_frontend/l10n/app_localizations.dart';

// ── Fake notifiers ────────────────────────────────────────────────────────────

class _FakeSessionNotifier extends SessionNotifier {
  final SessionState _fixed;
  _FakeSessionNotifier(this._fixed);
  @override
  SessionState build() => _fixed;
}

class _FakeMyBooksNotifier extends MyBooksNotifier {
  @override
  Future<List<Map<String, dynamic>>> build() async => [];
  @override
  Future<void> addOrUpdate({required String bookId, required String status, double? rating}) async {}
  @override
  Future<void> remove(String bookId) async {}
}

class _FakeRecsController extends UserRecommendationsController {
  @override
  Future<List<dynamic>> build() async => [];
}

// ── TestApp ───────────────────────────────────────────────────────────────────

/// Mirrors _MyAppState from main.dart — builds GoRouter using the widget's
/// WidgetRef so provider overrides propagate into the router's redirect.
class _TestApp extends ConsumerStatefulWidget {
  const _TestApp();

  @override
  ConsumerState<_TestApp> createState() => _TestAppState();
}

class _TestAppState extends ConsumerState<_TestApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = Routing(ref).router;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(textTheme: GoogleFonts.patrickHandTextTheme()),
      localizationsDelegates: const [
        S.delegate,
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
    );
  }
}

// ── Test app builder ──────────────────────────────────────────────────────────

Widget _testApp(SessionState session) => ProviderScope(
      overrides: [
        sessionProvider.overrideWith(() => _FakeSessionNotifier(session)),
        myBooksProvider.overrideWith(() => _FakeMyBooksNotifier()),
        userRecommendationsProvider.overrideWith(() => _FakeRecsController()),
        allGenresProvider.overrideWith((ref) async => <String>[]),
        if (session.userId != null) ...[
          userLibraryProvider(session.userId!).overrideWith((ref) async => null),
          libraryRecommendationsProvider(session.userId!)
              .overrideWith((ref) async => <dynamic>[]),
        ],
      ],
      child: const _TestApp(),
    );

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Suppresses RenderFlex overflow errors, which are layout issues in production
/// widgets unrelated to the routing logic being tested.
void _suppressOverflowErrors() {
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) return;
    original?.call(details);
  };
  // Will be restored at end of current test by the test framework teardown
  // pattern — we register our own via addTearDown inside each test.
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Auth routing (integration)', () {
    testWidgets('unauthenticated user lands on LoginPage', (tester) async {
      const session = SessionState(initialized: true);

      await tester.pumpWidget(_testApp(session));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('user with genre prefs is redirected to HomePage', (tester) async {
      // Must be set INSIDE testWidgets so we wrap the framework's own handler.
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      const session = SessionState(
        initialized: true,
        userId: 'u1',
        role: 'user',
        hasGenrePrefs: true,
      );

      await tester.pumpWidget(_testApp(session));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('user without genre prefs is redirected to genre-prefs onboarding',
        (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      const session = SessionState(
        initialized: true,
        userId: 'u1',
        role: 'user',
        hasGenrePrefs: false,
      );

      await tester.pumpWidget(_testApp(session));
      await tester.pumpAndSettle();

      expect(find.byType(PreferredGenre), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('librarian is redirected to HomePage (no genre-prefs gate)', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      const session = SessionState(
        initialized: true,
        userId: 'lib1',
        role: 'librarian',
      );

      await tester.pumpWidget(_testApp(session));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });
  });
}
