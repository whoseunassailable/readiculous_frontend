import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DisplaySnackbar {
  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showErrorWithFocus(
      {required BuildContext context,
      required String message,
      required FocusNode focusNode}) {
    FocusScope.of(context).requestFocus(focusNode);
    showError(context, message);
  }

  void showErrorWithoutFocus(
      {required BuildContext context, required String message}) {
    showError(context, message);
  }
}
