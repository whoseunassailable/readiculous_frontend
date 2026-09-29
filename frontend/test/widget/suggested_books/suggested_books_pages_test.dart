import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/core/network/api_error.dart';
import 'package:readiculous_frontend/core/session/session_notifier.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/core/session/session_state.dart';
import 'package:readiculous_frontend/features/my_books/presentation/state_management/my_books_provider.dart';
import 'package:readiculous_frontend/features/suggested_books/domain/entities/idle_book.dart';
import 'package:readiculous_frontend/features/suggested_books/domain/repositories/ml_repository.dart';
import 'package:readiculous_frontend/features/suggested_books/domain/repositories/shelf_repository.dart';
import 'package:readiculous_frontend/features/suggested_books/presentation/pages/library_picks_page.dart';
import 'package:readiculous_frontend/features/suggested_books/presentation/pages/user_recommendations_page.dart';
import 'package:readiculous_frontend/features/suggested_books/presentation/state_management/suggested_books_providers.dart';
import 'package:readiculous_frontend/shared/library/domain/entities/library.dart';
import 'package:readiculous_frontend/shared/library/presentation/state_management/library_providers.dart';
import 'package:readiculous_frontend/shared/recommendations/domain/entities/library_recommendation.dart';
import 'package:readiculous_frontend/shared/recommendations/domain/entities/user_recommendation.dart';
import 'package:readiculous_frontend/shared/recommendations/domain/repositories/recommendations_repository.dart';
import 'package:readiculous_frontend/shared/recommendations/presentation/state_management/recommendations_providers.dart';
import 'package:readiculous_frontend/shared/recommendations/presentation/state_management/user_recommendations_notifier.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

class _FixedRecommendations extends UserRecommendationsNotifier {
  final List<UserRecommendation> recs;
  _FixedRecommendations(this.recs);

  @override
  Future<List<UserRecommendation>> build() async => recs;
}

class _FakeMyBooks extends MyBooksNotifier {
  final List<Map<String, dynamic>> books;
  final added = <String>[];
  _FakeMyBooks(this.books);

  @override
  Future<List<Map<String, dynamic>>> build() async => books;

  @override
  Future<void> addOrUpdate(
      {required String bookId, required String status, double? rating}) async {
    added.add('$bookId:$status');
  }
}

class _FakeRecommendationsRepository implements RecommendationsRepository {
  ApiError? error;
  final calls = <String>[];

  @override
  Future<void> updateLibraryRecommendationState(
      int recommendationId, String state,
      {int? copies}) async {
    calls.add('state $recommendationId $state'
        '${copies == null ? '' : ' +$copies'}');
    if (error != null) throw error!;
  }

  @override
  Future<void> generateLibraryRecommendations(int libraryId,
      {int topNBooks = 10}) async {
    calls.add('generate $libraryId');
    if (error != null) throw error!;
  }

  @override
  Future<List<LibraryRecommendation>> getLibraryRecommendations(
          int libraryId) async =>
      _picks;

  @override
  Future<List<UserRecommendation>> getUserRecommendations(
          String userId) async =>
      [];

  @override
  Future<void> generateUserRecommendations(String userId,
      {int topN = 10}) async {}
}

class _FakeMl implements MlRepository {
  int retrained = 0;

  @override
  Future<void> retrain() async => retrained++;
}

class _FakeShelf implements ShelfRepository {
  final calls = <String>[];

  @override
  Future<IdleShelf> getIdleBooks(int libraryId) async => IdleShelf(
        libraryId: libraryId,
        idleDays: 180,
        totalTitles: 2,
        totalCopies: 4,
        books: [
          const IdleBook(
              bookId: 30,
              title: 'Batman: Inferno',
              author: 'Alex Irvine',
              copiesTotal: 3),
          IdleBook(
              bookId: 31,
              title: 'The Wild Children',
              copiesTotal: 1,
              lastActivity: DateTime.now().subtract(const Duration(days: 250))),
        ],
      );

  @override
  Future<void> removeCopies(int libraryId, int bookId, int copies) async =>
      calls.add('remove $libraryId $bookId $copies');
}

class _FixedSession extends SessionNotifier {
  @override
  SessionState build() =>
      const SessionState(initialized: true, userId: 'lib1', role: 'librarian');
}

// ── Data ──────────────────────────────────────────────────────────────────────

const _picks = [
  LibraryRecommendation(
    recommendationId: 5,
    libraryId: 4,
    bookId: 17,
    title: 'The Midnight Library',
    author: 'Matt Haig',
    demandScore: 0.96,
    demandLevel: 'HIGH',
    state: 'NEW',
    copiesTotal: 25,
    copiesAvailable: 0,
    readersWaiting: 10,
    backSoon: 4,
    readersPerMonth: 12,
  ),
  LibraryRecommendation(
    recommendationId: 6,
    libraryId: 4,
    bookId: 21,
    title: 'The Hunger Games',
    author: 'Suzanne Collins',
    demandScore: 0.91,
    demandLevel: 'HIGH',
    state: 'ORDERED',
  ),
];

const _userPicks = [
  UserRecommendation(
    recommendationId: 1,
    bookId: 100,
    title: 'Space Cats',
    author: 'A. Author',
    genres: ['Sci-Fi', 'Comedy'],
    score: 0.9,
  ),
  UserRecommendation(
    recommendationId: 2,
    bookId: 200,
    title: 'Quiet Murders',
    author: 'B. Author',
    genres: ['Mystery'],
    score: 0.8,
  ),
];

/// A genre chip in the horizontal filter row (cards also mention genres).
Finder _chip(String genre) => find.descendant(
      of: find.byWidgetPredicate(
          (w) => w is ListView && w.scrollDirection == Axis.horizontal),
      matching: find.text(genre),
    );

Future<void> _pump(WidgetTester tester, Widget page, List overrides) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [...overrides],
    child: MaterialApp(home: page),
  ));
  await tester.pumpAndSettle();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('UserRecommendationsPage', () {
    late _FakeMyBooks myBooks;

    Future<void> pumpPage(WidgetTester tester,
        {List<UserRecommendation> recs = _userPicks}) {
      myBooks = _FakeMyBooks([
        {'book_id': 200, 'status': 'reading'},
      ]);
      return _pump(tester, const UserRecommendationsPage(), [
        userRecommendationsProvider
            .overrideWith(() => _FixedRecommendations(recs)),
        myBooksProvider.overrideWith(() => myBooks),
      ]);
    }

    testWidgets('offers a filter chip per genre', (tester) async {
      await pumpPage(tester);

      for (final genre in ['All', 'Sci-Fi', 'Comedy', 'Mystery']) {
        expect(_chip(genre), findsOneWidget);
      }
      expect(find.text('Space Cats'), findsOneWidget);
      expect(find.text('Quiet Murders'), findsOneWidget);
    });

    testWidgets('filtering by genre hides the other picks', (tester) async {
      await pumpPage(tester);

      await tester.tap(_chip('Mystery'));
      await tester.pumpAndSettle();

      expect(find.text('Quiet Murders'), findsOneWidget);
      expect(find.text('Space Cats'), findsNothing);
    });

    testWidgets('books already in the reading list show "Added"',
        (tester) async {
      await pumpPage(tester);

      // Quiet Murders (book 200) is in the list; Space Cats isn't.
      expect(find.text('Added'), findsOneWidget);
      expect(find.text('ADD TO READING'), findsOneWidget);
    });

    testWidgets('"Add to reading" adds the book as want_to_read',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('ADD TO READING'));
      await tester.pumpAndSettle();

      expect(myBooks.added, ['100:want_to_read']);
    });

    testWidgets('no picks ⇒ the empty state', (tester) async {
      await pumpPage(tester, recs: const []);
      expect(find.text('No recommendations yet'), findsOneWidget);
    });
  });

  group('LibraryPicksPage', () {
    late _FakeRecommendationsRepository repo;
    late _FakeMl ml;
    late _FakeShelf shelf;

    Future<void> pumpPage(WidgetTester tester) {
      repo = _FakeRecommendationsRepository();
      ml = _FakeMl();
      shelf = _FakeShelf();
      return _pump(tester, const LibraryPicksPage(), [
        sessionProvider.overrideWith(_FixedSession.new),
        userLibraryProvider('lib1').overrideWith(
            (ref) async => const Library(libraryId: 4, name: 'Chinatown')),
        recommendationsRepositoryProvider.overrideWithValue(repo),
        mlRepositoryProvider.overrideWithValue(ml),
        shelfRepositoryProvider.overrideWithValue(shelf),
      ]);
    }

    Future<void> openMakeSpace(WidgetTester tester) async {
      await tester.tap(find.text('Make space (2)'));
      await tester.pumpAndSettle();
    }

    testWidgets('one tab per state, with counts; To review opens first',
        (tester) async {
      await pumpPage(tester);

      for (final tab in [
        'To review (1)',
        'Ordered (1)',
        'Stocked (0)',
        'Ignored (0)'
      ]) {
        expect(find.text(tab), findsOneWidget);
      }
      expect(find.text('The Midnight Library'), findsOneWidget);
      expect(find.text('The Hunger Games'), findsNothing);
      expect(find.text('96%'), findsOneWidget);
    });

    testWidgets('each tab shows only the picks in that state', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('Ordered (1)'));
      await tester.pumpAndSettle();
      expect(find.text('The Hunger Games'), findsOneWidget);
      expect(find.text('The Midnight Library'), findsNothing);

      await tester.tap(find.text('Stocked (0)'));
      await tester.pumpAndSettle();
      expect(find.text('No stocked books yet.'), findsOneWidget);

      await tester.tap(find.text('Ignored (0)'));
      await tester.pumpAndSettle();
      expect(find.text('No ignored books.'), findsOneWidget);
    });

    testWidgets('a decision is saved for that recommendation', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('Stocked').first);
      await tester.pumpAndSettle();

      expect(repo.calls, contains('state 5 STOCKED'));
      expect(
          find.text('"The Midnight Library" marked stocked. No order needed.'),
          findsOneWidget);
    });

    testWidgets('a pick shows its copies, readers and a suggestion',
        (tester) async {
      await pumpPage(tester);

      expect(find.text('0 of 25 available (25 lent out)'), findsOneWidget);
      expect(find.text('10 readers'), findsOneWidget);
      expect(find.text('~4 within 7 days (estimate)'), findsOneWidget);
      expect(find.text('~12 here'), findsOneWidget);
      expect(find.text('Suggested: order 6 copies.'), findsOneWidget);
    });

    testWidgets('Ordered asks how many copies, starting from the suggestion',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('Ordered'));
      await tester.pumpAndSettle();
      expect(find.text('Order copies'), findsOneWidget);
      expect(find.widgetWithText(TextField, '6'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '0');
      await tester.tap(find.text('Order'));
      await tester.pump();
      expect(find.text('Enter a number from 1 to 500'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '8');
      await tester.tap(find.text('Order'));
      await tester.pumpAndSettle();

      expect(repo.calls, ['state 5 ORDERED +8']);
      expect(
          find.text(
              'Ordered 8 copies of "The Midnight Library". Added to Stock.'),
          findsOneWidget);
    });

    testWidgets('cancelling an order changes nothing', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('Ordered'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(repo.calls, isEmpty);
      expect(find.text('Order copies'), findsNothing);
    });

    testWidgets('Make space lists books nobody uses, with a suggestion',
        (tester) async {
      await pumpPage(tester);
      await openMakeSpace(tester);

      expect(
          find.text('2 titles (4 copies) nobody here has read, borrowed or '
              'asked for in 6 months. Free their shelf space for books '
              'readers want.'),
          findsOneWidget);
      expect(find.text('Batman: Inferno'), findsOneWidget);
      expect(find.text('3 copies, none lent out'), findsOneWidget);
      expect(find.text('never'), findsOneWidget);
      expect(find.text('Suggested: keep 1, free 2 copies.'), findsOneWidget);
      expect(find.text('8 months ago'), findsOneWidget);
      expect(find.text('Suggested: remove it to make space.'), findsOneWidget);
    });

    testWidgets('freeing copies asks first, then removes them', (tester) async {
      await pumpPage(tester);
      await openMakeSpace(tester);

      await tester.tap(find.text('Free 2 copies'));
      await tester.pumpAndSettle();
      expect(
          find.text('Remove 2 copies of "Batman: Inferno" from Stock? '
              "You'll keep 1."),
          findsOneWidget);
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      expect(shelf.calls, ['remove 4 30 2']);
      expect(find.text('Removed 2 copies of "Batman: Inferno". You kept 1.'),
          findsOneWidget);
    });

    testWidgets('an only copy is removed from Stock; cancel does nothing',
        (tester) async {
      await pumpPage(tester);
      await openMakeSpace(tester);

      await tester.tap(find.text('Remove from Stock'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(shelf.calls, isEmpty);

      await tester.tap(find.text('Remove from Stock'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(shelf.calls, ['remove 4 31 1']);
      expect(
          find.text('"The Wild Children" removed from Stock.'), findsOneWidget);
    });

    testWidgets('each tab says what it holds', (tester) async {
      await pumpPage(tester);

      expect(
          find.text('Suggested titles and books your readers are waiting for. '
              'Check the copies, then decide.'),
          findsOneWidget);
      expect(find.text('Mark as:'), findsOneWidget);

      await tester.tap(find.text('Ordered (1)'));
      await tester.pumpAndSettle();
      expect(
          find.text(
              "Books you've ordered copies of. The copies are added to Stock."),
          findsOneWidget);
    });

    testWidgets('the ? button explains what each decision does',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();

      expect(find.text('How Library Picks work'), findsOneWidget);
      expect(find.text('You can change a decision at any time from any tab.'),
          findsOneWidget);
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();
      expect(find.text('How Library Picks work'), findsNothing);
    });

    testWidgets('a failed decision shows why', (tester) async {
      await pumpPage(tester);
      repo.error =
          const ApiError(statusCode: 404, message: 'Recommendation not found');

      await tester.tap(find.text('Ignored').first);
      await tester.pumpAndSettle();

      expect(find.text('Recommendation not found'), findsOneWidget);
    });

    testWidgets('Generate Picks runs for the librarian\'s library',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('Generate Picks'));
      await tester.pumpAndSettle();

      expect(repo.calls, contains('generate 4'));
    });

    testWidgets('Retrain asks first, then retrains', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byIcon(Icons.model_training));
      await tester.pumpAndSettle();
      expect(find.text('Retrain ML models?'), findsOneWidget);

      await tester.tap(find.text('Retrain'));
      await tester.pumpAndSettle();

      expect(ml.retrained, 1);
      expect(find.text('Models retrained successfully.'), findsOneWidget);
    });
  });
}
