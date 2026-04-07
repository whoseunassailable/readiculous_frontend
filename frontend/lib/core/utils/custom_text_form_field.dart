import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final Icon prefixIcon;

  const CustomTextFormField({
    required this.hintText,
    required this.controller,
    required this.prefixIcon,
    this.obscureText =
        false, // Default value is false, unless you want to specify it
  });

  @override
  Widget build(BuildContext context) {
    const borderRadius = 10.0;
    return TextFormField(
      controller: controller,
      obscureText: obscureText, // Use the obscureText parameter
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        hintText: hintText,
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }
}
