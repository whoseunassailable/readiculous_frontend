import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:readiculous_frontend/core/features/home/presentation/widgets/books_stock_container.dart';
import 'package:readiculous_frontend/core/features/home/presentation/widgets/bottom_navigation_for_home_page.dart';
import 'package:readiculous_frontend/core/features/home/presentation/widgets/heading_with_logo.dart';
import 'package:readiculous_frontend/core/features/home/presentation/widgets/mini_heading.dart';
import 'package:readiculous_frontend/core/features/home/presentation/widgets/page_header.dart';
import '../../../../../generated/l10n.dart';
import '../../../../constants/routes.dart';
import '../../../../widgets/crayon_genre_chip.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final genres = const ["Fantasy", "Mystery", "Sci-Fi", "Romance", "History"];
  Set<String> selectedGenres = {"Fantasy"};
  final genreColors = <String, Color>{
    "Fantasy": const Color(0xFFB7D8FF), // soft blue
    "Mystery": const Color(0xFFBFE3C0), // muted green
    "Sci-Fi": const Color(0xFFD7C6FF), // lavender
    "Romance": const Color(0xFFFFC7C2), // peach/pink
    "History": const Color(0xFFE8D2B0), // tan
  };

  // List of widgets for each tab
  final List<String> _pages = [
    RouteNames.profilePage,
    // RouteNames.updateInfoPage,
    RouteNames.logoutPage,
  ];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: height / 30),
              child: CrayonGenreChipRow(
                genres: genres,
                selected: selectedGenres,
                genreColors: genreColors,
                onChanged: (next) => setState(() => selectedGenres = next),
              ),
            ),
            SizedBox(height: height / 60),
            HeadingWithLogo(
              height: height,
              width: width,
              imageAssetName: 'assets/icons/books_to_stock_icon.png',
              heading: S.of(context).booksToStock,
            ),
            MiniHeading(height: height, width: width),
            SizedBox(height: height / 60),
            BooksStockContainer(height: height, width: width),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationForHomePage(),
    );
  }
}

//   dynamicRow({
//     required BuildContext context,
//     required double height,
//     required double width,
//     required String text_one,
//     required String text_two,
//     required void Function()? onTapOfContainerOne,
//     required void Function()? onTapOfContainerTwo,
//   }) {
//     return Row(
//       mainAxisSize: MainAxisSize.max,
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         RoundedContainer(
//           onTapOfContainer: onTapOfContainerOne,
//           text: text_one,
//           height: height,
//         ),
//         SizedBox(width: width / 15),
//         RoundedContainer(
//           onTapOfContainer: onTapOfContainerTwo,
//           text: text_two,
//           height: height,
//         )
//       ],
//     );
//   }
// }

// appBar: StylishAppBar(
//   title: AppLocalizations.of(context).readiculous,
//   homepage: true,
// ),

// Column(
//   mainAxisAlignment: MainAxisAlignment.center,
//   mainAxisSize: MainAxisSize.max,
//   children: [
//     Text(
//       AppLocalizations.of(context).findRecommendedBooksForUser,
//       style: TextStyles.bodyTextForContainer(),
//     ),
//     RoundedContainer(
//       onTapOfContainer: () =>
//           context.pushNamed(RouteNames.preferredGenre),
//       text:
//           AppLocalizations.of(context).findRecommendedBooksForUser,
//       height: height,
//     ),
//     SizedBox(height: height / 25),
//     RoundedContainer(
//       onTapOfContainer: () => context
//           .pushNamed(RouteNames.bookRecommendationPageForLibrary),
//       text: AppLocalizations.of(context)
//           .findRecommendedBooksForYourLibrary,
//       height: height,
//     ),
//   ],
// ),
