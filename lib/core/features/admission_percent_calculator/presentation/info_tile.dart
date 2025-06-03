import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_font_size.dart';

class InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final double height;

  const InfoTile(
      {super.key,
      required this.title,
      required this.value,
      required this.height});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title,
            style: TextStyle(
                color: AppColors.textColorForUniversityInfocard,
                fontWeight: FontWeight.bold,
                fontSize: height * AppFontSize.xxxl)),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textColorForUniversityInfocard,
            fontSize: height * AppFontSize.xxl,
          ),
        ),
      ],
    );
  }
}
