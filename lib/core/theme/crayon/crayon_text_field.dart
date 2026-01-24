import 'package:flutter/material.dart';
import 'crayon_styles.dart';

class CrayonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;

  const CrayonTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: CrayonStyles.handShadow(),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: CrayonStyles.inputText(),
        decoration: CrayonStyles.inputDecoration(hint),
      ),
    );
  }
}
