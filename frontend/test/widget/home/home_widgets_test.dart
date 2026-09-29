import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/core/session/session_notifier.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/core/session/session_state.dart';
import 'package:readiculous_frontend/features/home/presentation/pages/home_page.dart';
import 'package:readiculous_frontend/features/home/presentation/widgets/books_stock_container.dart';
import 'package:readiculous_frontend/features/my_books/presentation/state_management/my_books_provider.dart';
import 'package:readiculous_frontend/features/home/presentation/widgets/page_header.dart';
import 'package:readiculous_frontend/generated/l10n.dart';
import 'package:readiculous_frontend/shared/genres/domain/entities/genre.dart';
import 'package:readiculous_frontend/shared/genres/presentation/state_management/genres_providers.dart';
import 'package:readiculous_frontend/shared/library/domain/entities/library.dart';
import 'package:readiculous_frontend/shared/library/presentation/state_management/library_providers.dart';
import 'package:readiculous_frontend/shared/recommendations/domain/entities/library_recommendation.dart';
import 'package:readiculous_frontend/shared/recommendations/domain/entities/user_recommendation.dart';
import 'package:readiculous_frontend/shared/recommendations/presentation/state_management/recommendations_providers.dart';
import 'package:readiculous_frontend/shared/recommendations/presentation/state_management/user_recommendations_notifier.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

class _FixedSession extends SessionNotifier {
  final SessionState _state;
  _FixedSession(this._state);

  @override
  SessionState build() => _state;
}

const _librarian =
    SessionState(initialized: true, userId: 'lib1', role: 'librarian');
const _reader = SessionState(
    initialized: true, userId: 'u1', role: 'user', hasGenrePrefs: true);

const _chinatown = Library(libraryId: 4, name: 'Chinatown Branch');

class _NoRecommendations extends UserRecommendationsNotifier {
  @override
  Future<List<UserRecommendation>> build() async => [];

  @override
  Future<void> refresh() async {}
}

class _NoBooks extends MyBooksNotifier {
  @override
  Future<List<Map<String, dynamic>>> build() async => [];
}

LibraryRecommendation _rec(int id, String title, String state) =>
    LibraryRecommendation(
      recommendationId: id,
      libraryId: 4,
      bookId: id,
      title: title,
      author: 'Author $id',
      demandScore: 0.9,
      state: state,
    );

Future<void> _pump(
  WidgetTester tester,
  Widget child,
  List overrides,
) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [...overrides],
      child: MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('PageHeader', () {
    testWidgets('shows the reader\'s library name', (tester) async {
      await _pump(tester, const PageHeader(height: 600, width: 600), [
        sessionProvider.overrideWith(() => _FixedSession(_reader)),
        userLibraryProvider('u1').overrideWith((ref) async => _chinatown),
      ]);

      expect(find.text('Chinatown Branch'), findsOneWidget);
    });

    testWidgets('a reader with no library sees "No library assigned"',
        (tester) async {
      await _pump(tester, const PageHeader(height: 600, width: 600), [
        sessionProvider.overrideWith(() => _FixedSession(_reader)),
        userLibraryProvider('u1').overrideWith((ref) async => null),
      ]);

      expect(find.text('No library assigned'), findsOneWidget);
    });
  });

  group('BooksStockContainer (librarian)', () {
    const container =
        BooksStockContainer(height: 1200, width: 600, homePage: true);

    testWidgets('shows the first pending pick, skipping ones already acted on',
        (tester) async {
      await _pump(tester, container, [
        sessionProvider.overrideWith(() => _FixedSession(_librarian)),
        userLibraryProvider('lib1').overrideWith((ref) async => _chinatown),
        libraryRecommendationsProvider(4).overrideWith((ref) async => [
              _rec(1, 'Already Ordered', 'ORDERED'),
              _rec(2, 'The Midnight Library', 'NEW'),
              _rec(3, 'Another New One', 'NEW'),
            ]),
      ]);

      expect(find.text('The Midnight Library'), findsOneWidget);
      expect(find.text('Author 2'), findsOneWidget);
      expect(find.text('Already Ordered'), findsNothing);
    });

    testWidgets('says "No picks to review" when everything is handled',
        (tester) async {
      await _pump(tester, container, [
        sessionProvider.overrideWith(() => _FixedSession(_librarian)),
        userLibraryProvider('lib1').overrideWith((ref) async => _chinatown),
        libraryRecommendationsProvider(4).overrideWith((ref) async => [
              _rec(1, 'Stocked', 'STOCKED'),
              _rec(2, 'Ignored', 'IGNORED'),
            ]),
      ]);

      expect(find.text('No picks to review'), findsOneWidget);
    });

    testWidgets('a librarian without a library sees "No picks to review"',
        (tester) async {
      await _pump(tester, container, [
        sessionProvider.overrideWith(() => _FixedSession(_librarian)),
        userLibraryProvider('lib1').overrideWith((ref) async => null),
      ]);

      expect(find.text('No picks to review'), findsOneWidget);
    });

    testWidgets("offers no way to change the librarian's library",
        (tester) async {
      await _pump(tester, container, [
        sessionProvider.overrideWith(() => _FixedSession(_librarian)),
        userLibraryProvider('lib1').overrideWith((ref) async => _chinatown),
      ]);

      for (final chip in ['Picks', 'Trends', 'Stock', 'Database']) {
        expect(find.text(chip), findsOneWidget);
      }
      expect(find.text('Library'), findsNothing);
    });
  });

  group('HomePage genres', () {
    var genresRead = false;

    /// The whole dashboard at test-font widths overflows in places that
    /// don't matter here (layout is covered by the widget tests above).
    void suppressOverflowErrors() {
      final original = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        original?.call(details);
      };
      addTearDown(() => FlutterError.onError = original);
    }

    List overrides(SessionState session) {
      genresRead = false;
      return [
        sessionProvider.overrideWith(() => _FixedSession(session)),
        userLibraryProvider(session.userId!)
            .overrideWith((ref) async => _chinatown),
        libraryRecommendationsProvider(4).overrideWith((ref) async => []),
        userRecommendationsProvider.overrideWith(_NoRecommendations.new),
        myBooksProvider.overrideWith(_NoBooks.new),
        allGenresProvider.overrideWith((ref) async {
          genresRead = true;
          return const [
            Genre(genreId: 1, name: 'Classic'),
            Genre(genreId: 2, name: 'Mystery'),
          ];
        }),
        userGenresProvider.overrideWith((ref) async {
          genresRead = true;
          return const [Genre(genreId: 2, name: 'Mystery')];
        }),
      ];
    }

    testWidgets('a reader sees their genres', (tester) async {
      suppressOverflowErrors();
      await _pump(tester, const HomePage(), overrides(_reader));

      expect(find.text('Genre'), findsOneWidget);
      expect(find.text('Mystery'), findsOneWidget);
      expect(genresRead, true);
    });

    testWidgets('a librarian has no genre section at all', (tester) async {
      suppressOverflowErrors();
      await _pump(tester, const HomePage(), overrides(_librarian));

      expect(find.text('Books to Stock'), findsOneWidget);
      expect(find.text('Genre'), findsNothing);
      expect(find.text('Mystery'), findsNothing);
      expect(find.byIcon(Icons.tune_rounded), findsNothing);
      expect(genresRead, false, reason: "a librarian's genres aren't fetched");
    });
  });
}
