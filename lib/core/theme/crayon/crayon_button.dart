import 'package:flutter/material.dart';
import 'crayon_styles.dart';

class CrayonButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color fill;
  final Color textColor;

  const CrayonButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.fill,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: CrayonStyles.handShadow(),
      ),
      child: ElevatedButton(
        style: CrayonStyles.buttonStyle(fill: fill, textColor: textColor),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
