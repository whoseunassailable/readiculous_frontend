import 'package:flutter/material.dart';
import 'crayon_styles.dart';

class CrayonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color fill;
  final Color textColor;
  final bool isLoading;

  const CrayonButton({
    super.key,
    required this.label,
    this.onPressed,
    required this.fill,
    required this.textColor,
    this.isLoading = false,
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
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            : Text(label),
      ),
    );
  }
}
