import 'package:flutter/material.dart';
import 'package:readiculous_frontend/core/constants/app_font_size.dart';

class FormTextField extends StatelessWidget {
  final String text;
  final String fieldLabel;
  const FormTextField({
    super.key,
    required this.controller,
    required this.text,
    required this.fieldLabel,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: height * AppFontSize.m,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextField(
          controller: controller,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: fieldLabel,
            hintStyle: TextStyle(
              color: Colors.black.withOpacity(0.35),
              fontSize: 16,
            ),
            filled: true,
            fillColor: const Color(0xFFF3E6D8), // warm paper-like background
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.black.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.black.withOpacity(0.45),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
