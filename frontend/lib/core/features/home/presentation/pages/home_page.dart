import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/constants/app_roles.dart';
import 'package:readiculous_frontend/core/features/genre_preferences/presentation/state_management/genre_preferences_provider.dart';
import 'package:readiculous_frontend/core/features/home/presentation/state_management/genres_provider.dart';
import 'package:readiculous_frontend/core/features/suggested_books/presentation/state_management/user_recommendations_controller.dart';
import 'package:readiculous_frontend/core/features/home/presentation/widgets/books_stock_container.dart';
import 'package:readiculous_frontend/core/features/home/presentation/widgets/bottom_navigation_for_home_page.dart';
import 'package:readiculous_frontend/core/features/home/presentation/widgets/heading_with_logo.dart';
import 'package:readiculous_frontend/core/features/home/presentation/widgets/page_header.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import '../../../../../generated/l10n.dart';
import '../../../../widgets/crayon_genre_chip.dart';
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
      ref.read(userRecommendationsProvider.notifier).refresh();
    });
  }

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

  Map<String, Color> _buildGenreColors(List<String> genres) {
    return {
      for (var i = 0; i < genres.length; i++)
        genres[i]: _palette[i % _palette.length],
    };
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    final session = ref.watch(sessionProvider);
    final isLibrarian = session.role == AppRoles.librarian;
    final genresAsync = ref.watch(allGenresProvider);
    final preferredGenresAsync = ref.watch(genrePreferencesProvider);

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
                HeadingWithLogo(
                  height: height,
                  width: width,
                  imageAssetName: 'assets/icons/trending_genres_icon.png',
                  heading: S.of(context).genre,
                  trailing: isLibrarian
                      ? null
                      : GestureDetector(
                          onTap: () =>
                              context.pushNamed(RouteNames.genrePreferences),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3A436)
                                  .withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(999),
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
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
                genresAsync.when(
                  loading: () => const SizedBox(
                    height: 40,
                    child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (genres) {
                    final preferredGenres = preferredGenresAsync.asData?.value
                            .map((genre) => genre['name']?.toString() ?? '')
                            .where((name) => name.isNotEmpty)
                            .toList() ??
                        const <String>[];
                    final selectedGenres = preferredGenres.toSet();
                    final displayGenres =
                        preferredGenres.isNotEmpty ? preferredGenres : genres;
                    final genreColors = _buildGenreColors(genres);
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: height / 30),
                      child: CrayonGenreChipRow(
                        genres: displayGenres,
                        selected: selectedGenres,
                        genreColors: genreColors,
                        onChanged: (_) {},
                      ),
                    );
                  },
                ),
                SizedBox(height: height / 60),
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
