import 'package:flutter/material.dart';

class GenreChip extends StatelessWidget {
  final String genreText;
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;

  const GenreChip({
    super.key,
    required this.genreText,
    required this.bgColor,
    this.textColor = Colors.white,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor, // 👈 REAL background color
        borderRadius: BorderRadius.circular(14),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.2)
            : null,
      ),
      child: Text(
        genreText,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
