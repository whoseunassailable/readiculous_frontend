import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/features/my_books/presentation/state_management/my_books_provider.dart';
import '../../../../core/constants/app_roles.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/session/session_provider.dart';
import '../../../../core/widgets/crayon_genre_chip.dart';
import 'package:readiculous_frontend/shared/recommendations/presentation/state_management/user_recommendations_notifier.dart';
import 'package:readiculous_frontend/shared/recommendations/domain/entities/user_recommendation.dart';
import 'package:readiculous_frontend/shared/recommendations/presentation/state_management/recommendations_providers.dart';

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

    // Librarians: the first pick still waiting for a decision
    String? pendingBookTitle;
    String? pendingBookAuthor;
    if (isLibrarian) {
      final pending = ref
          .watch(currentLibraryRecommendationsProvider)
          .asData
          ?.value
          .where((r) => r.isPending)
          .firstOrNull;
      pendingBookTitle = pending?.title;
      pendingBookAuthor = pending?.author;
    }

    // Users: resolve top recommendations
    bool recLoading = false;
    List<UserRecommendation> userRecommendations = const [];
    if (!isLibrarian) {
      final recsAsync = ref.watch(userRecommendationsProvider);
      recLoading = recsAsync is AsyncLoading;
      final recs = recsAsync.asData?.value ?? const [];
      userRecommendations = homePage ? recs.take(3).toList() : recs;
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
      height: homePage ? _homeContainerHeight(height) : height * 0.5,
      width: width * 0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFB8743A), width: 5),
        image: const DecorationImage(
          image: AssetImage('assets/images/container_for_books.png'),
          fit: BoxFit.fitHeight,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final visibleRecommendationCount = homePage
              ? _homePreviewCountForHeight(
                  constraints.maxHeight,
                  userRecommendations.length,
                )
              : userRecommendations.length;
          final visibleRecommendations = userRecommendations
              .take(visibleRecommendationCount)
              .toList(growable: false);

          return Padding(
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
                            : Text('No picks to review',
                                style: TextStyle(
                                    fontSize: height / 55,
                                    color: Colors.black45)),
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
                              'Top picks for you right now',
                              style: GoogleFonts.patrickHand(
                                fontSize: height / 55,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF3A3329),
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
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
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
                            : Column(
                                children: [
                                  for (var index = 0;
                                      index < visibleRecommendations.length;
                                      index++) ...[
                                    if (index > 0) const SizedBox(height: 8),
                                    _buildUserRecommendationRow(
                                      context,
                                      ref,
                                      height,
                                      visibleRecommendations[index],
                                      readingStatusByBookId,
                                    ),
                                  ],
                                ],
                              ),
                  ),
                ],
                const SizedBox(height: 12),
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
                        onTap: () =>
                            context.pushNamed(RouteNames.libraryInventory),
                      ),
                      _ActionChip(
                        width: width * 0.22,
                        height: height / 18,
                        label: 'Database',
                        color: const Color(0xFFB7D8FF),
                        onTap: () => context.pushNamed(RouteNames.viewDatabase),
                      ),
                      // No "Library" chip: a librarian's library can't be
                      // changed. One without a library is sent to Choose
                      // Library from the Database page.
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
                          onTap: () =>
                              context.pushNamed(RouteNames.viewDatabase),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  static int _homePreviewCountForHeight(
      double containerHeight, int availableCount) {
    final desiredCount = switch (containerHeight) {
      < 320 => 1,
      < 420 => 2,
      _ => 3,
    };
    return availableCount < desiredCount ? availableCount : desiredCount;
  }

  static double _homeContainerHeight(double height) {
    return switch (height) {
      < 700 => height * 0.36,
      < 840 => height * 0.42,
      _ => height * 0.46,
    };
  }
}

class _UserRecommendationRow extends StatelessWidget {
  final double height;
  final UserRecommendation book;
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
    final title = book.title;
    final author = book.author ?? 'Unknown Author';
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
                      'ADD TO READING',
                      style: GoogleFonts.patrickHand(
                        fontSize: height / 88,
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

Widget _buildUserRecommendationRow(
  BuildContext context,
  WidgetRef ref,
  double height,
  UserRecommendation book,
  Map<String?, String> readingStatusByBookId,
) {
  final bookId = '${book.bookId}';
  final status = readingStatusByBookId[bookId];
  return _UserRecommendationRow(
    height: height,
    book: book,
    status: status,
    onAdd: () async {
      await ref.read(myBooksProvider.notifier).addOrUpdate(
            bookId: bookId,
            status: 'want_to_read',
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${book.title} added to reading')),
      );
    },
  );
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
    final chip = SizedBox(
      height: height,
      child: CrayonGenreChip(
        label: label,
        selected: false,
        onTap: onTap,
        color: color,
      ),
    );
    if (width == null) return chip;
    // At least [width] wide, but never narrower than the label needs
    // ("Database" overflowed on ~400px-wide phones).
    return IntrinsicWidth(
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: width!),
        child: chip,
      ),
    );
  }
}
