import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/core/session/session_notifier.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/core/session/session_state.dart';
import 'package:readiculous_frontend/features/library_inventory/domain/entities/catalog_book.dart';
import 'package:readiculous_frontend/features/library_inventory/domain/repositories/catalog_repository.dart';
import 'package:readiculous_frontend/features/library_inventory/presentation/pages/library_inventory_page.dart';
import 'package:readiculous_frontend/features/library_inventory/presentation/state_management/catalog_providers.dart';
import 'package:readiculous_frontend/features/library_inventory/presentation/state_management/library_inventory_provider.dart';
import 'package:readiculous_frontend/shared/library/domain/entities/library.dart';
import 'package:readiculous_frontend/shared/library/presentation/state_management/library_providers.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

const _stocked = {
  'library_id': 4,
  'book_id': 17,
  'title': 'The Midnight Library',
  'author': 'Matt Haig',
  'copies_total': 3,
  'copies_available': 2,
  'low_stock_threshold': 1,
};

class _FakeInventory extends LibraryInventoryNotifier {
  final saved = <String>[];

  @override
  Future<List<Map<String, dynamic>>> build() async => [_stocked];

  @override
  Future<void> saveInventoryItem({
    required String libraryId,
    required String bookId,
    required int copiesTotal,
    required int copiesAvailable,
    required int lowStockThreshold,
    bool isDeleted = false,
  }) async {
    saved.add('library $libraryId book $bookId '
        '$copiesTotal/$copiesAvailable/$lowStockThreshold');
  }
}

class _FakeCatalog implements CatalogRepository {
  final queries = <String>[];

  @override
  Future<List<CatalogBook>> searchBooks(String query, {int limit = 20}) async {
    queries.add(query);
    return const [
      CatalogBook(bookId: 441, title: 'Dune', author: 'Frank Herbert'),
      CatalogBook(bookId: 442, title: 'Dune Messiah', author: 'Frank Herbert'),
    ];
  }
}

class _FixedSession extends SessionNotifier {
  @override
  SessionState build() =>
      const SessionState(initialized: true, userId: 'lib1', role: 'librarian');
}

// ── Helpers ───────────────────────────────────────────────────────────────────

late _FakeInventory _inventory;
late _FakeCatalog _catalog;

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);

  _inventory = _FakeInventory();
  _catalog = _FakeCatalog();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sessionProvider.overrideWith(_FixedSession.new),
      userLibraryProvider('lib1').overrideWith(
          (ref) async => const Library(libraryId: 4, name: 'Chinatown')),
      libraryInventoryProvider.overrideWith(() => _inventory),
      catalogRepositoryProvider.overrideWithValue(_catalog),
    ],
    child: const MaterialApp(home: LibraryInventoryPage()),
  ));
  await tester.pumpAndSettle();
}

Finder _field(String label) => find.widgetWithText(TextField, label);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('Update Counts edits that book without touching the catalog',
      (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Update Counts'));
    await tester.pumpAndSettle();

    expect(find.text('Update Inventory'), findsOneWidget);
    expect(find.text('The Midnight Library'), findsNWidgets(2));
    expect(_field('Search title or author'), findsNothing);

    await tester.enterText(_field('Total'), '5');
    await tester.tap(find.text('Save Inventory'));
    await tester.pumpAndSettle();

    expect(_inventory.saved, ['library 4 book 17 5/2/1']);
    expect(_catalog.queries, isEmpty, reason: 'the catalog is ~85k books');
  });

  testWidgets('Add Book searches the catalog once typing pauses',
      (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Add Book'));
    await tester.pumpAndSettle();
    expect(
        find.text('Type a title or author to find the book.'), findsOneWidget);

    await tester.enterText(_field('Search title or author'), 'd');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(_field('Search title or author'), 'du');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(_field('Search title or author'), 'dune');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(_catalog.queries, ['dune'], reason: 'one request, not one per key');
    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('Dune Messiah'), findsOneWidget);

    await tester.tap(find.text('Dune Messiah'));
    await tester.pump();
    await tester.tap(find.text('Save Inventory'));
    await tester.pumpAndSettle();

    expect(_inventory.saved, ['library 4 book 442 1/1/1']);
  });

  testWidgets('one letter is not searched', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Add Book'));
    await tester.pumpAndSettle();
    await tester.enterText(_field('Search title or author'), 'd');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(_catalog.queries, isEmpty);
    expect(
        find.text('Type a title or author to find the book.'), findsOneWidget);
  });
}
