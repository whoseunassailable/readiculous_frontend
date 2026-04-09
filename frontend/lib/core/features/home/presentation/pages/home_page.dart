import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/constants/app_roles.dart';
import 'package:readiculous_frontend/core/features/home/presentation/state_management/genres_provider.dart';
import 'package:readiculous_frontend/core/features/home/presentation/widgets/books_stock_container.dart';
import 'package:readiculous_frontend/core/features/home/presentation/widgets/bottom_navigation_for_home_page.dart';
import 'package:readiculous_frontend/core/features/home/presentation/widgets/heading_with_logo.dart';
import 'package:readiculous_frontend/core/features/home/presentation/widgets/mini_heading.dart';
import 'package:readiculous_frontend/core/features/home/presentation/widgets/page_header.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import '../../../../../generated/l10n.dart';
import '../../../../widgets/crayon_genre_chip.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Set<String> selectedGenres = {};

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            PageHeader(height: height, width: width),
            SizedBox(height: height / 25),
            HeadingWithLogo(
              height: height,
              width: width,
              imageAssetName: 'assets/icons/trending_genres_icon.png',
              heading: S.of(context).trendingGenres,
            ),
            SizedBox(height: height / 60),
            genresAsync.when(
              loading: () => const SizedBox(
                height: 40,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (genres) {
                if (selectedGenres.isEmpty && genres.isNotEmpty) {
                  selectedGenres = {genres.first};
                }
                final genreColors = _buildGenreColors(genres);
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: height / 30),
                  child: CrayonGenreChipRow(
                    genres: genres,
                    selected: selectedGenres,
                    genreColors: genreColors,
                    onChanged: (next) => setState(() => selectedGenres = next),
                  ),
                );
              },
            ),
            SizedBox(height: height / 60),
            HeadingWithLogo(
              height: height,
              width: width,
              imageAssetName: 'assets/icons/books_to_stock_icon.png',
              heading: isLibrarian ? S.of(context).booksToStock : 'Your Reading Hub',
            ),
            MiniHeading(height: height, width: width, isLibrarian: isLibrarian),
            SizedBox(height: height / 60),
            BooksStockContainer(
              height: height,
              width: width,
              homePage: true,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationForHomePage(),
    );
  }
}
