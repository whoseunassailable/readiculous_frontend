import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/routes.dart';
import '../../../utils/appbar.dart';
import '../../../utils/text_styles.dart';
import '../../../widgets/dynamic_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of widgets for each tab
  final List<String> _pages = [
    RouteNames.profilePage,
    // RouteNames.updateInfoPage,
    RouteNames.logoutPage,
  ];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      // appBar: StylishAppBar(
      //   title: AppLocalizations.of(context).readiculous,
      //   homepage: true,
      // ),
      backgroundColor: AppColors.bgColorForHomePage,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitHeight,
            image: AssetImage('assets/images/home.png'),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   mainAxisSize: MainAxisSize.max,
            //   children: [
            //     Text(
            //       AppLocalizations.of(context).findRecommendedBooksForUser,
            //       style: TextStyles.bodyTextForContainer(),
            //     ),
            // RoundedContainer(
            //   onTapOfContainer: () =>
            //       context.pushNamed(RouteNames.preferredGenre),
            //   text:
            //       AppLocalizations.of(context).findRecommendedBooksForUser,
            //   height: height,
            // ),
            // SizedBox(height: height / 25),
            // RoundedContainer(
            //   onTapOfContainer: () => context
            //       .pushNamed(RouteNames.bookRecommendationPageForLibrary),
            //   text: AppLocalizations.of(context)
            //       .findRecommendedBooksForYourLibrary,
            //   height: height,
            // ),
            //   ],
            // ),
          ],
        ),
      ),
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
    );
  }

  dynamicRow({
    required BuildContext context,
    required double height,
    required double width,
    required String text_one,
    required String text_two,
    required void Function()? onTapOfContainerOne,
    required void Function()? onTapOfContainerTwo,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RoundedContainer(
          onTapOfContainer: onTapOfContainerOne,
          text: text_one,
          height: height,
        ),
        SizedBox(width: width / 15),
        RoundedContainer(
          onTapOfContainer: onTapOfContainerTwo,
          text: text_two,
          height: height,
        )
      ],
    );
  }
}
