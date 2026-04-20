import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/core/features/my_books/presentation/pages/my_books_page.dart';
import 'package:readiculous_frontend/core/features/my_books/presentation/state_management/my_books_provider.dart';
import 'package:readiculous_frontend/core/features/suggested_books/presentation/state_management/user_recommendations_controller.dart';
import 'package:readiculous_frontend/core/session/session_notifier.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/core/session/session_state.dart';
import 'package:readiculous_frontend/generated/l10n.dart';

// ── Fake notifiers ────────────────────────────────────────────────────────────

class _FakeSessionNotifier extends SessionNotifier {
  final SessionState _fixed;
  _FakeSessionNotifier(this._fixed);
  @override
  SessionState build() => _fixed;
}

class _FakeMyBooksNotifier extends MyBooksNotifier {
  final List<Map<String, dynamic>> _books;
  _FakeMyBooksNotifier(this._books);

  @override
  Future<List<Map<String, dynamic>>> build() async => _books;

  @override
  Future<void> addOrUpdate({
    required String bookId,
    required String status,
    double? rating,
  }) async {
    // no-op: we test side-effects, not network calls
  }

  @override
  Future<void> remove(String bookId) async {}
}

/// Tracks how many times its build() is called.
/// Capturing [_log] by reference lets us observe re-builds caused by
/// ref.invalidate() even though each invalidation creates a new notifier.
class _TrackingRecsController extends UserRecommendationsController {
  final List<int> _log;
  _TrackingRecsController(this._log);

  @override
  Future<List<dynamic>> build() async {
    _log.add(_log.length);
    return [];
  }
}

// ── Helper ────────────────────────────────────────────────────────────────────

const _loggedInSession = SessionState(
  initialized: true,
  userId: 'u1',
  role: 'user',
  hasGenrePrefs: true,
);

Widget _buildTestApp({List<Map<String, dynamic>> books = const []}) {
  return ProviderScope(
    overrides: [
      sessionProvider.overrideWith(() => _FakeSessionNotifier(_loggedInSession)),
      myBooksProvider.overrideWith(() => _FakeMyBooksNotifier(books)),
      userRecommendationsProvider.overrideWith(() => _TrackingRecsController([])),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: const MyBooksPage(),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('MyBooksPage widget', () {
    // ── Tabs ──────────────────────────────────────────────────────────────
    group('tabs', () {
      testWidgets('renders the three status tabs', (tester) async {
        await tester.pumpWidget(_buildTestApp());
        await tester.pumpAndSettle();

        expect(find.text('Reading'), findsOneWidget);
        expect(find.text('Want to Read'), findsOneWidget);
        expect(find.text('Finished'), findsOneWidget);
      });
    });

    // ── Empty states ──────────────────────────────────────────────────────
    group('empty states', () {
      testWidgets('Reading tab shows empty-state message when no books', (tester) async {
        await tester.pumpWidget(_buildTestApp());
        await tester.pumpAndSettle();

        expect(find.textContaining('Start reading something'), findsOneWidget);
      });

      testWidgets('Want to Read tab shows empty-state message', (tester) async {
        await tester.pumpWidget(_buildTestApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Want to Read'));
        await tester.pumpAndSettle();

        expect(find.textContaining('wishlist is empty'), findsOneWidget);
      });

      testWidgets('Finished tab shows empty-state message', (tester) async {
        await tester.pumpWidget(_buildTestApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Finished'));
        await tester.pumpAndSettle();

        expect(find.textContaining('No finished books'), findsOneWidget);
      });
    });

    // ── Book cards ────────────────────────────────────────────────────────
    group('book cards', () {
      testWidgets('reading book shows title, author and Finished Reading button', (tester) async {
        await tester.pumpWidget(_buildTestApp(books: [
          {
            'book_id': '1',
            'title': 'The Great Gatsby',
            'author': 'F. Scott Fitzgerald',
            'status': 'reading',
          },
        ]));
        await tester.pumpAndSettle();

        expect(find.text('The Great Gatsby'), findsOneWidget);
        expect(find.textContaining('F. Scott Fitzgerald'), findsOneWidget);
        expect(find.text('Finished Reading'), findsOneWidget);
      });

      testWidgets('want-to-read book shows Remove button', (tester) async {
        await tester.pumpWidget(_buildTestApp(books: [
          {
            'book_id': '2',
            'title': 'Dune',
            'author': 'Frank Herbert',
            'status': 'want_to_read',
          },
        ]));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Want to Read'));
        await tester.pumpAndSettle();

        expect(find.text('Dune'), findsOneWidget);
        expect(find.text('Remove'), findsOneWidget);
      });

      testWidgets('finished book shows star rating row', (tester) async {
        await tester.pumpWidget(_buildTestApp(books: [
          {
            'book_id': '3',
            'title': '1984',
            'author': 'George Orwell',
            'status': 'read',
            'rating': 4.0,
          },
        ]));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Finished'));
        await tester.pumpAndSettle();

        expect(find.text('1984'), findsOneWidget);
        expect(find.textContaining('George Orwell'), findsOneWidget);
        // Star rating row should be visible
        expect(find.byIcon(Icons.star_rounded), findsWidgets);
      });

      testWidgets('multiple books in the same tab are all shown', (tester) async {
        await tester.pumpWidget(_buildTestApp(books: [
          {'book_id': '1', 'title': 'Book One', 'author': 'A', 'status': 'reading'},
          {'book_id': '2', 'title': 'Book Two', 'author': 'B', 'status': 'reading'},
          {'book_id': '3', 'title': 'Book Three', 'author': 'C', 'status': 'reading'},
        ]));
        await tester.pumpAndSettle();

        expect(find.text('Book One'), findsOneWidget);
        expect(find.text('Book Two'), findsOneWidget);
        expect(find.text('Book Three'), findsOneWidget);
      });
    });

    // ── Finished Reading flow ─────────────────────────────────────────────
    group('mark as finished', () {
      testWidgets('tapping Finished Reading opens the rating sheet', (tester) async {
        await tester.pumpWidget(_buildTestApp(books: [
          {'book_id': '1', 'title': 'Test Book', 'author': 'Author', 'status': 'reading'},
        ]));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Finished Reading'));
        await tester.pumpAndSettle();

        expect(find.text('How was the book?'), findsOneWidget);
        expect(find.text('Mark as Finished'), findsOneWidget);
      });

      testWidgets('completing the flow invalidates userRecommendationsProvider', (tester) async {
        final buildLog = <int>[];

        await tester.pumpWidget(ProviderScope(
          overrides: [
            sessionProvider.overrideWith(() => _FakeSessionNotifier(_loggedInSession)),
            myBooksProvider.overrideWith(() => _FakeMyBooksNotifier([
              {'book_id': '1', 'title': 'Test Book', 'author': 'Author', 'status': 'reading'},
            ])),
            userRecommendationsProvider.overrideWith(
              () => _TrackingRecsController(buildLog),
            ),
          ],
          child: MaterialApp(
            builder: (context, child) => Consumer(
              builder: (context, ref, _) {
                ref.watch(userRecommendationsProvider);
                return child!;
              },
            ),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: const MyBooksPage(),
          ),
        ));
        await tester.pumpAndSettle();

        final buildsBeforeFinish = buildLog.length;

        // Open rating sheet.
        await tester.tap(find.text('Finished Reading'));
        await tester.pumpAndSettle();

        // Select a star.
        await tester.tap(find.byIcon(Icons.star_outline_rounded).first);
        await tester.pump();

        // Confirm.
        await tester.tap(find.text('Mark as Finished'));
        await tester.pumpAndSettle();

        expect(
          buildLog.length,
          greaterThan(buildsBeforeFinish),
          reason: 'userRecommendationsProvider should be invalidated after marking finished',
        );
      });
    });

    // ── Rating update ─────────────────────────────────────────────────────
    group('rating update', () {
      testWidgets('updating rating on a finished book invalidates userRecommendationsProvider',
          (tester) async {
        final buildLog = <int>[];

        await tester.pumpWidget(ProviderScope(
          overrides: [
            sessionProvider.overrideWith(() => _FakeSessionNotifier(_loggedInSession)),
            myBooksProvider.overrideWith(() => _FakeMyBooksNotifier([
              {'book_id': '2', 'title': 'Old Book', 'author': 'Author', 'status': 'read', 'rating': 3.0},
            ])),
            userRecommendationsProvider.overrideWith(
              () => _TrackingRecsController(buildLog),
            ),
          ],
          child: MaterialApp(
            builder: (context, child) => Consumer(
              builder: (context, ref, _) {
                ref.watch(userRecommendationsProvider);
                return child!;
              },
            ),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: const MyBooksPage(),
          ),
        ));
        await tester.pumpAndSettle();

        // Navigate to Finished tab.
        await tester.tap(find.text('Finished'));
        await tester.pumpAndSettle();

        final buildsBeforeRating = buildLog.length;

        // Tap the first (lowest) star to update rating.
        await tester.tap(find.byIcon(Icons.star_outline_rounded).first);
        await tester.pumpAndSettle();

        expect(
          buildLog.length,
          greaterThan(buildsBeforeRating),
          reason: 'userRecommendationsProvider should be invalidated after re-rating',
        );
      });
    });
  });
}
