import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';

class StylishAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  bool homepage = false;

  StylishAppBar({
    super.key,
    required this.title,
    required this.homepage,
  });

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: height / 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Oswald',
        ),
      ),
      backgroundColor: const Color(0xFFF3A436), // Background color
      elevation: 4.0, // Shadow for depth
      centerTitle: true,
      leading: homepage
          ? IconButton(
              icon:
                  const Icon(MaterialCommunityIcons.menu, color: Colors.white),
              onPressed: () => context.pop(),
            )
          : IconButton(
              icon: const Icon(MaterialCommunityIcons.arrow_left,
                  color: Colors.white),
              onPressed: () => context.pop(),
            ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16.0), // Rounded bottom corners
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
