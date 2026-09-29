import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/constants/app_roles.dart';
import 'package:readiculous_frontend/shared/genres/presentation/state_management/genres_providers.dart';
import 'package:readiculous_frontend/shared/recommendations/presentation/state_management/user_recommendations_notifier.dart';
import 'package:readiculous_frontend/features/home/presentation/widgets/books_stock_container.dart';
import 'package:readiculous_frontend/features/home/presentation/widgets/bottom_navigation_for_home_page.dart';
import 'package:readiculous_frontend/features/home/presentation/widgets/heading_with_logo.dart';
import 'package:readiculous_frontend/features/home/presentation/widgets/page_header.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import '../../../../generated/l10n.dart';
import '../../../../core/widgets/crayon_genre_chip.dart';
import 'package:go_router/go_router.dart';
import 'package:readiculous_frontend/core/constants/routes.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // Only readers see personal recommendations on the dashboard.
      if (ref.read(sessionProvider).role == AppRoles.librarian) return;
      ref.read(userRecommendationsProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    final session = ref.watch(sessionProvider);
    final isLibrarian = session.role == AppRoles.librarian;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitHeight,
            image: AssetImage(
              'assets/images/home.png',
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                PageHeader(height: height, width: width),
                SizedBox(height: height / 80),
                // Readers only: librarians have no genre preferences.
                if (!isLibrarian) ...[
                  HeadingWithLogo(
                    height: height,
                    width: width,
                    imageAssetName: 'assets/icons/trending_genres_icon.png',
                    heading: S.of(context).genre,
                    trailing: GestureDetector(
                      onTap: () =>
                          context.pushNamed(RouteNames.genrePreferences),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3A436).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.black, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                offset: Offset(1, 1),
                                blurRadius: 0)
                          ],
                        ),
                        child: const Icon(Icons.tune_rounded,
                            size: 18, color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(height: height / 60),
                  _ReaderGenres(height: height),
                  SizedBox(height: height / 60),
                ],
                HeadingWithLogo(
                  height: height,
                  width: width,
                  imageAssetName: 'assets/icons/books_to_stock_icon.png',
                  heading: isLibrarian
                      ? S.of(context).booksToStock
                      : 'Your Reading Hub',
                ),
                SizedBox(height: height / 60),
                Expanded(
                  child: BooksStockContainer(
                    height: height,
                    width: width,
                    homePage: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigationForHomePage(),
    );
  }
}

/// The reader's preferred genres (all genres until they pick some).
class _ReaderGenres extends ConsumerWidget {
  final double height;

  const _ReaderGenres({required this.height});

  static const _palette = [
    Color(0xFFB7D8FF), // soft blue
    Color(0xFFBFE3C0), // muted green
    Color(0xFFD7C6FF), // lavender
    Color(0xFFFFC7C2), // peach/pink
    Color(0xFFE8D2B0), // tan
    Color(0xFFFFE4A0), // pale yellow
    Color(0xFFFFCCE5), // light pink
    Color(0xFFB2EBF2), // light cyan
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferredGenresAsync = ref.watch(userGenresProvider);
    return ref.watch(allGenresProvider).when(
          loading: () => const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (allGenres) {
            final genres = allGenres.map((g) => g.name).toList();
            final preferredGenres = preferredGenresAsync.asData?.value
                    .map((genre) => genre.name)
                    .toList() ??
                const <String>[];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: height / 30),
              child: CrayonGenreChipRow(
                genres: preferredGenres.isNotEmpty ? preferredGenres : genres,
                selected: preferredGenres.toSet(),
                genreColors: {
                  for (var i = 0; i < genres.length; i++)
                    genres[i]: _palette[i % _palette.length],
                },
                onChanged: (_) {},
              ),
            );
          },
        );
  }
}
