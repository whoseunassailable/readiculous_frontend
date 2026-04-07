import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../generated/l10n.dart';
import '../../../../constants/app_roles.dart';
import '../../../../constants/routes.dart';
import '../../../../session/session_provider.dart';
import '../../../../widgets/crayon_genre_chip.dart';
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

    // Resolve library + pending recommendation for librarians
    String? pendingBookTitle;
    String? pendingBookAuthor;
    if (isLibrarian) {
      final libraryAsync = ref.watch(userLibraryProvider(userId));
      libraryAsync.whenData((library) {
        if (library != null) {
          final recsAsync = ref.watch(
            libraryRecommendationsProvider(library.libraryId.toString()),
          );
          recsAsync.whenData((recs) {
            final pending = recs
                .cast<Map<String, dynamic>>()
                .where((r) => r['state'] == 'NEW' || r['state'] == null)
                .toList();
            if (pending.isNotEmpty) {
              pendingBookTitle = pending.first['title'] as String?;
              pendingBookAuthor = pending.first['author'] as String?;
            }
          });
        }
      });
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
                Image.asset(
                  "assets/icons/blue_book_icon.png",
                  height: height / 12,
                ),
                SizedBox(width: width / 40),
                if (isLibrarian && pendingBookTitle != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pendingBookTitle!,
                          style: TextStyle(
                            fontSize: height / 50,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (pendingBookAuthor != null)
                          Text(
                            pendingBookAuthor!,
                            style: TextStyle(fontSize: height / 65),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            const Divider(color: Colors.brown, thickness: 2),
            const Spacer(),
            // --- BOTTOM BUTTONS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: isLibrarian
                  ? [
                      SizedBox(
                        width: width * 0.32,
                        height: height / 18,
                        child: CrayonGenreChip(
                          label: 'View Recommendations',
                          selected: false,
                          onTap: () => context.pushNamed(
                              RouteNames.bookRecommendationPageForLibrary),
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: width * 0.32,
                        height: height / 18,
                        child: CrayonGenreChip(
                          label: S.of(context).viewDatabase,
                          selected: false,
                          onTap: () =>
                              context.pushNamed(RouteNames.viewDatabase),
                          color: Colors.white,
                        ),
                      ),
                    ]
                  : [
                      SizedBox(
                        width: width * 0.32,
                        height: height / 18,
                        child: CrayonGenreChip(
                          label: 'My Recommendations',
                          selected: false,
                          onTap: () => context.pushNamed(
                              RouteNames.bookRecommendationPageForUser),
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: width * 0.32,
                        height: height / 18,
                        child: CrayonGenreChip(
                          label: 'My Genres',
                          selected: false,
                          onTap: () =>
                              context.pushNamed(RouteNames.preferredGenre),
                          color: Colors.white,
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
