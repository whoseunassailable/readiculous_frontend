import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/core/widgets/minimalistic_button.dart';
import 'package:readiculous_frontend/features/genre_preferences/presentation/pages/genre_onboarding_page.dart';
import 'package:readiculous_frontend/features/genre_preferences/presentation/pages/genre_preferences_page.dart';
import 'package:readiculous_frontend/features/genre_preferences/presentation/state_management/genre_preferences_controller.dart';
import 'package:readiculous_frontend/shared/recommendations/domain/entities/user_recommendation.dart';
import 'package:readiculous_frontend/shared/recommendations/presentation/state_management/user_recommendations_notifier.dart';
import 'package:readiculous_frontend/generated/l10n.dart';
import 'package:readiculous_frontend/shared/genres/domain/entities/genre.dart';
import 'package:readiculous_frontend/shared/genres/presentation/state_management/genres_providers.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

/// Records the ids it's asked to save and reports success.
class _RecordingController extends GenrePreferencesController {
  Set<int>? saved;

  @override
  FutureOr<void> build() {}

  @override
  Future<void> save(Set<int> genreIds) async {
    state = const AsyncLoading();
    saved = genreIds;
    state = const AsyncData(null);
  }
}

class _RecordingRecommendations extends UserRecommendationsNotifier {
  int generated = 0;

  @override
  Future<List<UserRecommendation>> build() async => [];

  @override
  Future<void> generate({int topN = 10}) async => generated++;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

const _catalog = [
  Genre(genreId: 1, name: 'Action'),
  Genre(genreId: 2, name: 'Fantasy'),
  Genre(genreId: 3, name: 'Mystery'),
];

/// Opens [page] on top of a placeholder home so "go back" has somewhere to go.
Future<void> _pump(WidgetTester tester, Widget page, List overrides) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);

  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('HOME'))),
    GoRoute(path: '/home_page', builder: (_, __) => const Text('HOME')),
    GoRoute(path: '/page', builder: (_, __) => page),
  ]);
  await tester.pumpWidget(ProviderScope(
    overrides: [...overrides],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
    ),
  ));
  router.push('/page');
  await tester.pumpAndSettle();
}

Finder _chip(String name) => find.text(name);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('GenrePreferencesPage', () {
    late _RecordingController controller;
    late _RecordingRecommendations recommendations;

    Future<void> pumpPage(WidgetTester tester, List<Genre> saved) {
      controller = _RecordingController();
      recommendations = _RecordingRecommendations();
      return _pump(tester, const GenrePreferencesPage(), [
        allGenresProvider.overrideWith((ref) async => _catalog),
        userGenresProvider.overrideWith((ref) async => saved),
        genrePreferencesControllerProvider.overrideWith(() => controller),
        userRecommendationsProvider.overrideWith(() => recommendations),
      ]);
    }

    Future<void> tapSave(WidgetTester tester) async {
      await tester.tap(find.text('Save Preferences'));
      await tester.pumpAndSettle();
    }

    testWidgets('starts from the saved genres', (tester) async {
      await pumpPage(tester, const [Genre(genreId: 2, name: 'Fantasy')]);

      expect(find.text('1 genre selected'), findsOneWidget);
    });

    testWidgets('saves the toggled selection by id, then goes back',
        (tester) async {
      await pumpPage(tester, const [Genre(genreId: 2, name: 'Fantasy')]);

      await tester.tap(_chip('Action')); // add
      await tester.tap(_chip('Fantasy')); // remove
      await tester.pump();
      expect(find.text('1 genre selected • unsaved changes'), findsOneWidget);

      await tapSave(tester);

      expect(controller.saved, {1});
      expect(recommendations.generated, 1,
          reason: 'new tastes ⇒ fresh recommendations');
      expect(find.byType(GenrePreferencesPage), findsNothing);
      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('at least one genre is required', (tester) async {
      await pumpPage(tester, const [Genre(genreId: 2, name: 'Fantasy')]);

      await tester.tap(_chip('Fantasy'));
      await tester.pump();
      await tapSave(tester);

      expect(controller.saved, isNull);
      expect(find.text('Please select at least one genre'), findsOneWidget);
      expect(find.byType(GenrePreferencesPage), findsOneWidget);
    });
  });

  group('GenreOnboardingPage', () {
    late _RecordingController controller;

    Future<void> pumpPage(WidgetTester tester) {
      controller = _RecordingController();
      return _pump(tester, const GenreOnboardingPage(), [
        allGenresProvider.overrideWith((ref) async => _catalog),
        genrePreferencesControllerProvider.overrideWith(() => controller),
      ]);
    }

    testWidgets('has no back arrow: there is nothing to go back to',
        (tester) async {
      // Onboarding is reached by redirect, so it's the only page.
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          allGenresProvider.overrideWith((ref) async => _catalog),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(routes: [
            GoRoute(path: '/', builder: (_, __) => const GenreOnboardingPage()),
          ]),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(BackButton), findsNothing);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('picking genres saves their ids', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('Select genres'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fantasy'));
      await tester.tap(find.text('Mystery'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MinimalistButton));
      await tester.pumpAndSettle();

      expect(controller.saved, {2, 3});
    });

    testWidgets('continuing without a genre is refused', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byType(MinimalistButton));
      await tester.pump();

      expect(controller.saved, isNull);
      expect(find.text('Please select at least one genre'), findsOneWidget);
    });
  });
}
