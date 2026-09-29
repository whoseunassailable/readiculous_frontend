import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final Icon prefixIcon;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;

  /// Shows [hintText] as a floating label, so the field stays identifiable
  /// once it has a value (useful for pre-filled edit forms).
  final bool showLabel;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.prefixIcon,
    this.focusNode,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.showLabel = false,
    this.obscureText =
        false, // Default value is false, unless you want to specify it
  });

  @override
  Widget build(BuildContext context) {
    const borderRadius = 10.0;
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      obscureText: obscureText, // Use the obscureText parameter
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        labelText: showLabel ? hintText : null,
        hintText: showLabel ? null : hintText,
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }
}
