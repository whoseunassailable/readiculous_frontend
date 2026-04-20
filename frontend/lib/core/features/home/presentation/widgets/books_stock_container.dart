import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/core/features/my_books/presentation/state_management/my_books_provider.dart';
import '../../../../constants/app_roles.dart';
import '../../../../constants/routes.dart';
import '../../../../session/session_provider.dart';
import '../../../../widgets/crayon_genre_chip.dart';
import 'package:readiculous_frontend/core/features/suggested_books/presentation/state_management/user_recommendations_controller.dart';
import '../state_management/library_recommendations_provider.dart';
import '../state_management/user_library_provider.dart';

class BooksStockContainer extends ConsumerWidget {
  final double height;
  final double width;
  final bool homePage;

  const BooksStockContainer({
    super.key,
    required this.height,
    required this.width,
    required this.homePage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final userRole = session.role;
    final userId = session.userId;

    final isLibrarian = userRole == AppRoles.librarian && userId != null;

    // Librarians: resolve pending ML recommendation
    String? pendingBookTitle;
    String? pendingBookAuthor;
    if (isLibrarian) {
      final library = ref.watch(userLibraryProvider(userId)).asData?.value;
      if (library != null) {
        final recs = ref
            .watch(libraryRecommendationsProvider(library.libraryId.toString()))
            .asData
            ?.value;
        if (recs != null) {
          final pending = recs
              .cast<Map<String, dynamic>>()
              .where((r) => r['state'] == 'NEW' || r['state'] == null)
              .toList();
          if (pending.isNotEmpty) {
            pendingBookTitle = pending.first['title'] as String?;
            pendingBookAuthor = pending.first['author'] as String?;
          }
        }
      }
    }

    // Users: resolve top recommendations
    bool recLoading = false;
    List<Map<String, dynamic>> userRecommendations = const [];
    if (!isLibrarian) {
      final recsAsync = ref.watch(userRecommendationsProvider);
      recLoading = recsAsync is AsyncLoading;
      final recs = recsAsync.asData?.value;
      if (recs != null && recs.isNotEmpty) {
        userRecommendations = recs
            .cast<Map<String, dynamic>>()
            .where(_isDisplayableRecommendation)
            .toList();
        if (homePage && userRecommendations.length > 3) {
          userRecommendations = userRecommendations.take(3).toList();
        }
      }
    }

    final readingList = !isLibrarian
        ? ref.watch(myBooksProvider).asData?.value ?? const []
        : const <Map<String, dynamic>>[];
    final readingStatusByBookId = {
      for (final item in readingList)
        item['book_id']?.toString():
            item['status']?.toString() ?? 'want_to_read',
    };

    return Container(
      height: homePage ? height * 0.42 : height * 0.5,
      width: width * 0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFB8743A), width: 5),
        image: const DecorationImage(
          image: AssetImage('assets/images/container_for_books.png'),
          fit: BoxFit.fitHeight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLibrarian) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset("assets/icons/blue_book_icon.png",
                      height: height / 12),
                  SizedBox(width: width / 40),
                  Expanded(
                    child: pendingBookTitle != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pendingBookTitle,
                                style: TextStyle(
                                    fontSize: height / 50,
                                    fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (pendingBookAuthor != null)
                                Text(pendingBookAuthor,
                                    style: TextStyle(
                                        fontSize: height / 65,
                                        color: Colors.black54)),
                            ],
                          )
                        : Text('No pending picks',
                            style: TextStyle(
                                fontSize: height / 55, color: Colors.black45)),
                  ),
                ],
              ),
              const Divider(color: Colors.brown, thickness: 2),
              const Spacer(),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Books to Read',
                          style: GoogleFonts.patrickHand(
                            fontSize: height / 55,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3A3329),
                          ),
                        ),
                        Text(
                          homePage
                              ? 'Top picks for you right now'
                              : 'Based on your saved recommendations',
                          style: GoogleFonts.patrickHand(
                            fontSize: height / 78,
                            color:
                                const Color(0xFF3A3329).withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (homePage)
                    GestureDetector(
                      onTap: () => context.pushNamed(
                        RouteNames.bookRecommendationPageForUser,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD7C6FF),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: Text(
                          'See all',
                          style: GoogleFonts.patrickHand(
                            fontSize: height / 80,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF3A3329),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: recLoading
                    ? const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFFB8743A),
                          ),
                        ),
                      )
                    : userRecommendations.isEmpty
                        ? Center(
                            child: Text(
                              'No recommendations yet.\nRate books and update genres first.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.patrickHand(
                                fontSize: height / 65,
                                color: const Color(0xFF3A3329)
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: userRecommendations.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final book = userRecommendations[index];
                              final bookId = book['book_id']?.toString() ?? '';
                              final status = readingStatusByBookId[bookId];
                              return _UserRecommendationRow(
                                height: height,
                                book: book,
                                status: status,
                                onAdd: bookId.isEmpty
                                    ? null
                                    : () async {
                                        await ref
                                            .read(myBooksProvider.notifier)
                                            .addOrUpdate(
                                              bookId: bookId,
                                              status: 'want_to_read',
                                            );
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${book['title']} added to Want to Read',
                                            ),
                                          ),
                                        );
                                      },
                              );
                            },
                          ),
              ),
            ],
            // --- BOTTOM BUTTONS ---

            if (isLibrarian)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 10,
                children: [
                  _ActionChip(
                    width: width * 0.22,
                    height: height / 18,
                    label: 'Picks',
                    color: const Color(0xFFD7C6FF),
                    onTap: () => context.pushNamed(
                      RouteNames.bookRecommendationPageForLibrary,
                    ),
                  ),
                  _ActionChip(
                    width: width * 0.22,
                    height: height / 18,
                    label: 'Trends',
                    color: const Color(0xFFFFE4A0),
                    onTap: () => context.pushNamed(RouteNames.genreTrends),
                  ),
                  _ActionChip(
                    width: width * 0.22,
                    height: height / 18,
                    label: 'Stock',
                    color: const Color(0xFFFFC7C2),
                    onTap: () => context.pushNamed(RouteNames.libraryInventory),
                  ),
                  _ActionChip(
                    width: width * 0.22,
                    height: height / 18,
                    label: 'Database',
                    color: const Color(0xFFB7D8FF),
                    onTap: () => context.pushNamed(RouteNames.viewDatabase),
                  ),
                  _ActionChip(
                    width: width * 0.22,
                    height: height / 18,
                    label: 'Library',
                    color: const Color(0xFFBFE3C0),
                    onTap: () =>
                        context.pushNamed(RouteNames.libraryAssociation),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _ActionChip(
                      height: height / 18,
                      label: 'My Books',
                      color: const Color(0xFFBFE3C0),
                      onTap: () => context.pushNamed(RouteNames.myBooks),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionChip(
                      height: height / 18,
                      label: 'Library',
                      color: const Color(0xFFB7D8FF),
                      onTap: () => context.pushNamed(RouteNames.viewDatabase),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _UserRecommendationRow extends StatelessWidget {
  final double height;
  final Map<String, dynamic> book;
  final String? status;
  final VoidCallback? onAdd;

  const _UserRecommendationRow({
    required this.height,
    required this.book,
    required this.status,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final title = book['title']?.toString() ?? 'Unknown Title';
    final author = book['author']?.toString() ?? 'Unknown Author';
    final isAdded = status != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB8743A), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFB7D8FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Center(
              child: Image.asset(
                'assets/icons/blue_book_icon.png',
                width: 20,
                height: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.patrickHand(
                    fontSize: height / 72,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3A3329),
                  ),
                ),
                Text(
                  author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.patrickHand(
                    fontSize: height / 88,
                    color: const Color(0xFF3A3329).withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          isAdded
              ? _UserStatusPill(status: status!)
              : GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7C6FF),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.black, width: 1.8),
                    ),
                    child: Text(
                      'Add',
                      style: GoogleFonts.patrickHand(
                        fontSize: height / 68,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4D3277),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

bool _hasMojibake(String text) => RegExp(r'[ÐÑÃ�]').hasMatch(text);

bool _isDisplayableRecommendation(Map<String, dynamic> book) {
  final title = book['title']?.toString().trim() ?? '';
  final author = book['author']?.toString().trim() ?? '';

  if (title.isEmpty) return false;
  if (_hasMojibake(title) || _hasMojibake(author)) return false;
  return true;
}

class _UserStatusPill extends StatelessWidget {
  final String status;

  const _UserStatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final String label;
    switch (status) {
      case 'reading':
        color = const Color(0xFFBFE3C0);
        label = 'Reading';
        break;
      case 'read':
        color = const Color(0xFFFFE4A0);
        label = 'Finished';
        break;
      default:
        color = const Color(0xFFDDE8A6);
        label = 'Added';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black, width: 1.6),
      ),
      child: Text(
        label,
        style: GoogleFonts.patrickHand(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF3A3329),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final double? width;
  final double height;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    this.width,
    required this.height,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CrayonGenreChip(
        label: label,
        selected: false,
        onTap: onTap,
        color: color,
      ),
    );
  }
}
