import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class UniversityInfoCardStyles {
  static BoxDecoration containerDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    color: AppColors.darkYellow.withOpacity(0.9),
    boxShadow: const [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 20,
        spreadRadius: 2,
        offset: Offset(20, 10),
      ),
    ],
  );

  static ButtonStyle applyButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.applyButtonColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  );

  static EdgeInsets containerPadding = const EdgeInsets.all(20);
}
