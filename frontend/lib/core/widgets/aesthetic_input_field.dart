import 'package:flutter/material.dart';

import '../utils/text_styles.dart';

class AestheticInputField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType inputType;
  final bool obscureText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  AestheticInputField({
    required this.hintText,
    required this.controller,
    this.inputType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width * 0.8,
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        obscureText: obscureText,
        validator: validator,
        style: TextStyles.bodyTextForContainer(),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16.0,
            color: Colors.grey.shade500,
          ),
          prefixIcon:
              prefixIcon != null ? Icon(prefixIcon, color: Colors.grey) : null,
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding:
              EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.blue.shade300, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.red.shade300, width: 2.0),
          ),
        ),
      ),
    );
  }
}
