import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:readiculous_frontend/core/features/home/presentation/state_management/user_library_provider.dart';
import 'package:readiculous_frontend/core/network/clients/books_api_client.dart';
import 'package:readiculous_frontend/core/network/clients/library_books_api_client.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import '../state_management/my_books_provider.dart';
import '../widgets/my_book_card.dart';

class MyBooksPage extends ConsumerWidget {
  const MyBooksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(myBooksProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/images/bg_for_add_books.png'),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ── Custom crayon header ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3A436),
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: Colors.black, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                              MaterialCommunityIcons.arrow_left,
                              color: Colors.black,
                              size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'My Books',
                        style: GoogleFonts.patrickHand(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3A3329),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _CrayonTabBar(),
              const SizedBox(height: 8),
              Expanded(
                child: booksAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Text(
                      'Could not load books.\nTry again.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.patrickHand(fontSize: 16),
                    ),
                  ),
                  data: (books) => _BookTabView(books: books),
                ),
              ),
            ],
          ),
        ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFF3A436),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          onPressed: () => _showAddBookSheet(context, ref),
          child: const Icon(Icons.add, color: Colors.black, size: 28),
        ),
      ),
    );
  }

  void _showAddBookSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddBookSheet(),
    );
  }
}

// ─── Tab bar ────────────────────────────────────────────────────────────────

class _CrayonTabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TabBar(
      labelStyle: GoogleFonts.patrickHand(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: GoogleFonts.patrickHand(fontSize: 13),
      labelColor: Colors.black,
      unselectedLabelColor: Colors.black54,
      dividerColor: Colors.transparent,
      indicator: BoxDecoration(
        color: const Color(0xFFBFE3C0),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      tabs: const [
        Tab(text: 'Reading'),
        Tab(text: 'Want to Read'),
        Tab(text: 'Finished'),
      ],
    );
  }
}

// ─── Tab view ────────────────────────────────────────────────────────────────

class _BookTabView extends ConsumerWidget {
  final List<Map<String, dynamic>> books;

  const _BookTabView({required this.books});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reading = books.where((b) => b['status'] == 'reading').toList();
    final wantToRead =
        books.where((b) => b['status'] == 'want_to_read').toList();
    final finished = books.where((b) => b['status'] == 'read').toList();

    return TabBarView(
      children: [
        _BookList(
          books: reading,
          emptyMsg: "Nothing here yet.\nStart reading something!",
        ),
        _BookList(
          books: wantToRead,
          emptyMsg: "Your wishlist is empty.\nAdd something good!",
        ),
        _BookList(
          books: finished,
          emptyMsg: "No finished books yet.\nKeep reading!",
        ),
      ],
    );
  }
}

void _showRatingSheet(BuildContext context, WidgetRef ref, String bookId) {
  double selectedRating = 0;
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModal) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFDF3),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Colors.black, width: 2),
            left: BorderSide(color: Colors.black, width: 2),
            right: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How was the book?', style: GoogleFonts.patrickHand(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF3A3329))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => GestureDetector(
                onTap: () => setModal(() => selectedRating = i + 1.0),
                child: Icon(
                  (i + 1) <= selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 40,
                  color: const Color(0xFFF3A436),
                ),
              )),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(myBooksProvider.notifier).addOrUpdate(
                    bookId: bookId,
                    status: 'read',
                    rating: selectedRating > 0 ? selectedRating : null,
                  );
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3A436),
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                  shadowColor: Colors.black,
                ),
                child: Text('Mark as Finished', style: GoogleFonts.patrickHand(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BookList extends ConsumerWidget {
  final List<Map<String, dynamic>> books;
  final String emptyMsg;

  const _BookList({required this.books, required this.emptyMsg});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (books.isEmpty) {
      return Center(
        child: Text(
          emptyMsg,
          textAlign: TextAlign.center,
          style: GoogleFonts.patrickHand(
            fontSize: 18,
            color: const Color(0xFF3A3329).withOpacity(0.45),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: books.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final book = books[i];
        final bookId = book['book_id'].toString();
        final status = book['status'] as String? ?? 'want_to_read';

        return MyBookCard(
          book: book,
          onDelete: () => ref.read(myBooksProvider.notifier).remove(bookId),
          onRate: status == 'read'
              ? (rating) => ref.read(myBooksProvider.notifier).addOrUpdate(
                    bookId: bookId,
                    status: 'read',
                    rating: rating,
                  )
              : null,
          onMarkFinished: status == 'reading'
              ? () => _showRatingSheet(context, ref, bookId)
              : null,
          onMoveToReading: status == 'read'
              ? () => ref.read(myBooksProvider.notifier).addOrUpdate(
                    bookId: bookId,
                    status: 'reading',
                  )
              : null,
        );
      },
    );
  }
}

// ─── Add book bottom sheet ───────────────────────────────────────────────────

class _AddBookSheet extends ConsumerStatefulWidget {
  const _AddBookSheet();

  @override
  ConsumerState<_AddBookSheet> createState() => _AddBookSheetState();
}

class _AddBookSheetState extends ConsumerState<_AddBookSheet> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _allBooks = [];
  List<Map<String, dynamic>> _filtered = [];
  String _status = 'want_to_read';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _searchCtrl.addListener(_filter);
  }

  Future<void> _loadBooks() async {
    try {
      List<dynamic> raw;
      final userId = ref.read(sessionProvider).userId;
      if (userId != null) {
        final library = await ref.read(userLibraryProvider(userId).future);
        if (library != null) {
          raw = await LibraryBooksApiClient(DioClient.main)
              .getBooksInLibrary(library.libraryId.toString());
        } else {
          raw = await BooksApiClient(DioClient.main).getAllBooks();
        }
      } else {
        raw = await BooksApiClient(DioClient.main).getAllBooks();
      }
      if (mounted) {
        setState(() {
          _allBooks = raw.cast<Map<String, dynamic>>();
          _filtered = _allBooks;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _allBooks
          : _allBooks
              .where((b) =>
                  (b['title'] as String? ?? '').toLowerCase().contains(q) ||
                  (b['author'] as String? ?? '').toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Container(
      height: h * 0.78,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.black, width: 2),
          left: BorderSide(color: Colors.black, width: 2),
          right: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // drag handle
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Add a Book',
            style: GoogleFonts.patrickHand(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3A3329),
            ),
          ),
          const SizedBox(height: 14),
          // Status selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statusChip(
                    'want_to_read', 'Want to Read', const Color(0xFFB7D8FF)),
                const SizedBox(width: 8),
                _statusChip('reading', 'Reading', const Color(0xFFBFE3C0)),
                const SizedBox(width: 8),
                _statusChip('read', 'Finished', const Color(0xFFD7C6FF)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      offset: Offset(2, 2),
                      blurRadius: 0),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                style: GoogleFonts.patrickHand(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search by title or author...',
                  hintStyle: GoogleFonts.patrickHand(
                      color: Colors.black38, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Book results
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No books found.',
                          style: GoogleFonts.patrickHand(fontSize: 16),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final book = _filtered[i];
                          return GestureDetector(
                            onTap: () async {
                              await ref
                                  .read(myBooksProvider.notifier)
                                  .addOrUpdate(
                                    bookId: book['book_id'].toString(),
                                    status: _status,
                                  );
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.black, width: 1.5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(2, 2),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          book['title'] as String? ?? '',
                                          style: GoogleFonts.patrickHand(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF3A3329),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'by ${book['author'] ?? ''}',
                                          style: GoogleFonts.patrickHand(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.add_circle_outline,
                                    color: Color(0xFFF3A436),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String value, String label, Color color) {
    final selected = _status == value;
    return GestureDetector(
      onTap: () => setState(() => _status = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.35),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black, width: selected ? 2.5 : 1.5),
          boxShadow: selected
              ? const [
                  BoxShadow(
                      color: Colors.black38,
                      offset: Offset(2, 2),
                      blurRadius: 0)
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.patrickHand(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
