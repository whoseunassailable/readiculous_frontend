import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../generated/l10n.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/routes.dart';
import '../../../utils/appbar.dart';
import '../../../utils/text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/dynamic_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
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
      backgroundColor: AppColors.bgColorForHomePage,
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
            SizedBox(height: height / 7.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(width: width / 6),
                Image.asset(
                  'assets/icons/library_pulse_icon.png',
                  height: height / 25,
                ),
                SizedBox(width: width / 15),
                Text(
                  S.of(context).libraryPulse,
                  style: TextStyle(
                      fontSize: height / 30, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: width / 6),
                Text(
                  S.of(context).whatReadersWant,
                  style: TextStyle(
                    fontSize: height / 45,
                  ),
                ),
              ],
            ),
            SizedBox(height: height / 30),
            Row(
              children: [
                SizedBox(width: width / 12),
                Image.asset(
                  'assets/icons/trending_genres_icon.png',
                  height: height / 25,
                ),
                SizedBox(width: width / 24),
                Text(
                  S.of(context).trendingGenres,
                  style: TextStyle(
                      fontSize: height / 30, fontWeight: FontWeight.w500),
                ),
              ],
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
            Row(
              children: [
                SizedBox(width: width / 12),
                Image.asset(
                  'assets/icons/books_to_stock_icon.png',
                  height: height / 25,
                ),
                SizedBox(width: width / 24),
                Text(
                  S.of(context).booksToStock,
                  style: TextStyle(
                      fontSize: height / 30, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: width / 12),
                Text(
                  S.of(context).basedOnCollectedReaderData,
                  style: TextStyle(
                    fontSize: height / 45,
                  ),
                ),
              ],
            ),
            SizedBox(height: height / 60),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/container_for_books.png',
                height: height * 0.42,
                fit: BoxFit.fitHeight,
                width: width * 0.8,
              ),
            ),
          ],
        ),
      ),
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

// bottomNavigationBar: BottomNavigationBar(
//   currentIndex: _selectedIndex,
//   onTap: (index) {
//     // Navigate to the selected page
//     setState(() {
//       _selectedIndex = index;
//     });
//     context.pushNamed(_pages[index]);
//   }, //
//   backgroundColor: const Color(0xFFF3A436),
//   selectedItemColor: Colors.black,
//   unselectedItemColor: Colors.black,
//   type: BottomNavigationBarType
//       .fixed, // Allows more than 3 items in the nav bar
//   items: const <BottomNavigationBarItem>[
//     BottomNavigationBarItem(
//       icon: Icon(MaterialCommunityIcons.account),
//       label: 'Profile',
//     ),
//     // BottomNavigationBarItem(
//     //   icon: Icon(Icons.edit),
//     //   label: 'Update Info',
//     // ),
//     BottomNavigationBarItem(
//       icon: Icon(MaterialCommunityIcons.logout, color: Colors.black),
//       label: 'Log out',
//     ),
//   ],
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
