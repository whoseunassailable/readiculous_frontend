import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/core/network/api_error.dart';
import 'package:readiculous_frontend/core/session/session_notifier.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/core/session/session_state.dart';
import 'package:readiculous_frontend/features/library_association/presentation/pages/library_association_page.dart';
import 'package:readiculous_frontend/features/library_association/presentation/state_management/library_association_controller.dart';
import 'package:readiculous_frontend/shared/library/domain/entities/library.dart';
import 'package:readiculous_frontend/shared/library/domain/repositories/library_repository.dart';
import 'package:readiculous_frontend/shared/library/presentation/state_management/library_providers.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

class _FakeRepository implements LibraryRepository {
  final calls = <String>[];
  ApiError? error;

  @override
  Future<void> setReaderLibrary(String userId, int libraryId) async {
    calls.add('reader $userId $libraryId');
    if (error != null) throw error!;
  }

  @override
  Future<void> assignLibrarian(String userId, int libraryId) async {
    calls.add('librarian $userId $libraryId');
    if (error != null) throw error!;
  }

  @override
  Future<Library?> getUserLibrary(String userId) async => null;

  @override
  Future<List<Library>> getAllLibraries() async => [];
}

class _FixedSession extends SessionNotifier {
  final SessionState _state;
  _FixedSession(this._state);

  @override
  SessionState build() => _state;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

const _catalog = [
  Library(libraryId: 4, name: 'Chinatown', location: 'Chicago, IL'),
  Library(libraryId: 7, name: 'Harold Washington', location: 'Chicago, IL'),
  Library(libraryId: 9, name: 'Queens Central', location: 'Jamaica, NY'),
];

/// Opens Choose Library on top of a placeholder home so saving can go back.
Future<_FakeRepository> _pump(
  WidgetTester tester, {
  String role = 'user',
  Library? current,
  List<Library> catalog = _catalog,
}) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);

  final repo = _FakeRepository();
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('HOME'))),
    GoRoute(
        path: '/library', builder: (_, __) => const LibraryAssociationPage()),
  ]);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sessionProvider.overrideWith(() => _FixedSession(
          SessionState(initialized: true, userId: 'u1', role: role))),
      libraryRepositoryProvider.overrideWithValue(repo),
      allLibrariesProvider.overrideWith((ref) async => catalog),
      userLibraryProvider('u1').overrideWith((ref) async => current),
    ],
    child: MaterialApp.router(routerConfig: router),
  ));
  router.push('/library');
  await tester.pumpAndSettle();
  return repo;
}

Finder get _save => find.byType(FloatingActionButton);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('lists every library with its location', (tester) async {
    await _pump(tester);

    expect(find.text('Chinatown'), findsOneWidget);
    expect(find.text('Harold Washington'), findsOneWidget);
    expect(find.text('Jamaica, NY'), findsOneWidget);
    expect(_save, findsNothing, reason: 'nothing picked yet');
  });

  testWidgets('search matches the name or the location', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField), 'queens');
    await tester.pump();
    expect(find.text('Queens Central'), findsOneWidget);
    expect(find.text('Chinatown'), findsNothing);

    await tester.enterText(find.byType(TextField), 'chicago');
    await tester.pump();
    expect(find.text('Chinatown'), findsOneWidget);
    expect(find.text('Harold Washington'), findsOneWidget);
    expect(find.text('Queens Central'), findsNothing);

    await tester.enterText(find.byType(TextField), 'nowhere');
    await tester.pump();
    expect(find.text('No libraries match\n"nowhere"'), findsOneWidget);
  });

  testWidgets('the current library is shown and preselected', (tester) async {
    await _pump(tester, current: _catalog.first);

    expect(find.text('Current: Chinatown'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text('Save Library'), findsOneWidget);
  });

  testWidgets('a reader saves the picked library and goes back',
      (tester) async {
    final repo = await _pump(tester);

    await tester.tap(find.text('Harold Washington'));
    await tester.pumpAndSettle(); // the Save button animates in
    await tester.tap(_save);
    await tester.pumpAndSettle();

    expect(repo.calls, ['reader u1 7']);
    expect(find.text('Preferred library saved.'), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('a librarian without a library picks one, warned it is final',
      (tester) async {
    final repo = await _pump(tester, role: 'librarian');

    expect(find.text("Pick the library you manage. You can't change it later."),
        findsOneWidget);
    await tester.tap(find.text('Chinatown'));
    await tester.pumpAndSettle(); // the Save button animates in
    expect(find.text('Save Association'), findsOneWidget);
    await tester.tap(_save);
    await tester.pumpAndSettle();

    expect(repo.calls, ['librarian u1 4']);
    expect(find.text('Library association saved.'), findsOneWidget);
  });

  testWidgets('a reader with a library can still switch', (tester) async {
    final repo = await _pump(tester, current: _catalog.first);

    expect(find.text('Choose Library'), findsOneWidget);
    await tester.tap(find.text('Queens Central'));
    await tester.pumpAndSettle();
    await tester.tap(_save);
    await tester.pumpAndSettle();

    expect(repo.calls, ['reader u1 9']);
  });

  testWidgets(
      "the server's refusal is shown when a librarian's save is refused",
      (tester) async {
    final repo = await _pump(tester, role: 'librarian');
    repo.error = const ApiError(
        statusCode: 409, message: "A librarian's library can't be changed");

    await tester.tap(find.text('Chinatown'));
    await tester.pumpAndSettle();
    await tester.tap(_save);
    await tester.pumpAndSettle();

    expect(
        find.text(
            "Could not save library: A librarian's library can't be changed"),
        findsOneWidget);
  });

  testWidgets('a rejected save says why and stays open', (tester) async {
    final repo = await _pump(tester);
    repo.error = const ApiError(statusCode: 404, message: 'Library not found');

    await tester.tap(find.text('Chinatown'));
    await tester.pumpAndSettle(); // the Save button animates in
    await tester.tap(_save);
    await tester.pumpAndSettle();

    expect(
        find.text('Could not save library: Library not found'), findsOneWidget);
    expect(find.text('Choose Library'), findsOneWidget);
    expect(find.text('HOME'), findsNothing);
  });

  testWidgets('only the visible cards of a huge catalog are built',
      (tester) async {
    await _pump(tester, catalog: [
      for (var i = 0; i < 16000; i++) Library(libraryId: i, name: 'Library $i'),
    ]);

    expect(find.text('Library 0'), findsOneWidget);
    expect(find.text('Library 15999', skipOffstage: false), findsNothing);
  });
}
