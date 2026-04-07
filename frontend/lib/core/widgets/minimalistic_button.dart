import 'package:flutter/material.dart';

class MinimalistButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const MinimalistButton(
      {super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width * 0.4, // Adjust the button width to be 80% of screen width
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.white, width: 2.0),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Center(
          // Ensure the text is centered within the button
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18, // Slightly bigger font size for better readability
              fontWeight: FontWeight.bold, // Bolder text for better visibility
            ),
          ),
        ),
      ),
    );
  }
}
