import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../constants/app_roles.dart';
import '../../../../constants/routes.dart';
import '../../../../session/session_provider.dart';
import '../../../../widgets/crayon_genre_chip.dart';
import '../state_management/library_recommendations_provider.dart';
import '../state_management/user_library_provider.dart';
import 'package:readiculous_frontend/core/features/my_books/presentation/state_management/my_books_provider.dart';

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
            .asData?.value;
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

    // Users: resolve currently-reading book
    String? currentBookTitle;
    String? currentBookAuthor;
    if (!isLibrarian) {
      final books = ref.watch(myBooksProvider).asData?.value;
      if (books != null) {
        final reading = books.where((b) => b['status'] == 'reading').toList();
        if (reading.isNotEmpty) {
          currentBookTitle = reading.first['title'] as String?;
          currentBookAuthor = reading.first['author'] as String?;
        }
      }
    }

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset("assets/icons/blue_book_icon.png", height: height / 12),
                SizedBox(width: width / 40),
                Expanded(
                  child: isLibrarian
                      ? (pendingBookTitle != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pendingBookTitle!,
                                  style: TextStyle(fontSize: height / 50, fontWeight: FontWeight.w600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (pendingBookAuthor != null)
                                  Text(pendingBookAuthor!, style: TextStyle(fontSize: height / 65, color: Colors.black54)),
                              ],
                            )
                          : Text('No pending picks', style: TextStyle(fontSize: height / 55, color: Colors.black45)))
                      : (currentBookTitle != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Currently reading',
                                  style: TextStyle(fontSize: height / 65, color: Colors.black45),
                                ),
                                Text(
                                  currentBookTitle!,
                                  style: TextStyle(fontSize: height / 50, fontWeight: FontWeight.w600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (currentBookAuthor != null)
                                  Text(currentBookAuthor!, style: TextStyle(fontSize: height / 65, color: Colors.black54)),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nothing in progress',
                                  style: TextStyle(fontSize: height / 55, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Pick something from My Books!',
                                  style: TextStyle(fontSize: height / 65, color: Colors.black45),
                                ),
                              ],
                            )),
                ),
              ],
            ),
            const Divider(color: Colors.brown, thickness: 2),
            const Spacer(),
            // --- BOTTOM BUTTONS ---

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 10,
              children: isLibrarian
                  ? [
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
                      _ActionChip(
                        width: width * 0.22,
                        height: height / 18,
                        label: 'Library',
                        color: const Color(0xFFBFE3C0),
                        onTap: () =>
                            context.pushNamed(RouteNames.libraryAssociation),
                      ),
                    ]
                  : [
                      _ActionChip(
                        width: width * 0.22,
                        height: height / 18,
                        label: 'My Books',
                        color: const Color(0xFFBFE3C0),
                        onTap: () => context.pushNamed(RouteNames.myBooks),
                      ),
                      _ActionChip(
                        width: width * 0.22,
                        height: height / 18,
                        label: 'My Recs',
                        color: const Color(0xFFD7C6FF),
                        onTap: () => context.pushNamed(
                          RouteNames.bookRecommendationPageForUser,
                        ),
                      ),
                      _ActionChip(
                        width: width * 0.22,
                        height: height / 18,
                        label: 'Genres',
                        color: const Color(0xFFFFE4A0),
                        onTap: () =>
                            context.pushNamed(RouteNames.genrePreferences),
                      ),
                      _ActionChip(
                        width: width * 0.22,
                        height: height / 18,
                        label: 'Library',
                        color: const Color(0xFFB7D8FF),
                        onTap: () => context.pushNamed(RouteNames.viewDatabase),
                      ),
                    ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final double width;
  final double height;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.width,
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
