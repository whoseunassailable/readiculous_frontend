import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CrayonStyles {
  static const Color ink = Colors.black;
  static const Color purpleInk = Color(0xFF6A5ACD);

  static TextStyle title(double height) => GoogleFonts.patrickHand(
        fontSize: height * 0.04,
        fontWeight: FontWeight.w600,
        color: ink,
      );

  static TextStyle subtitle(double height) => GoogleFonts.patrickHand(
        fontSize: height * 0.018,
        fontStyle: FontStyle.italic,
        color: ink,
      );

  static TextStyle inputText() => GoogleFonts.patrickHand(
        fontSize: 18,
        color: ink,
      );

  static TextStyle hint() => GoogleFonts.patrickHand(
        fontSize: 18,
        color: ink.withOpacity(0.55),
      );

  static TextStyle link() => GoogleFonts.patrickHand(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: ink,
      );

  static List<BoxShadow> handShadow() => [
        BoxShadow(
          color: ink.withOpacity(0.12),
          offset: const Offset(2, 3),
          blurRadius: 0,
        ),
      ];

  static InputDecoration inputDecoration(String hintText) {
    final borderColor = ink.withOpacity(0.65);

    return InputDecoration(
      hintText: hintText,
      hintStyle: hint(),
      filled: true,
      fillColor: Colors.white.withOpacity(0.92),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(width: 2.6, color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(width: 3.2, color: borderColor),
      ),
    );
  }

  static ButtonStyle buttonStyle({
    required Color fill,
    required Color textColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: fill,
      foregroundColor: textColor,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: ink.withOpacity(0.65),
          width: 2.6,
        ),
      ),
      textStyle: GoogleFonts.patrickHand(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
