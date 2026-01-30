import 'package:flutter/cupertino.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../../../../generated/l10n.dart';

class BottomNavigationForHomePage extends StatefulWidget {
  const BottomNavigationForHomePage({super.key});

  @override
  State<BottomNavigationForHomePage> createState() =>
      _BottomNavigationForHomePageState();
}

class _BottomNavigationForHomePageState
    extends State<BottomNavigationForHomePage> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Container(
      height: height * 0.09,
      width: width,
      alignment: Alignment.bottomCenter,
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fitHeight,
          image: AssetImage('assets/images/bottom_nav_bg.png'),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  GestureDetector(
                      child:
                          const Icon(MaterialCommunityIcons.face_man_profile)),
                  Text(S.of(context).profile),
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                      child: const Icon(MaterialCommunityIcons.logout)),
                  Text(S.of(context).logOut),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
