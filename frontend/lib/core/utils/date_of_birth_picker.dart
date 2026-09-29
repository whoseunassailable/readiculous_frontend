import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Opens a calendar for a date of birth and writes the pick into
/// [controller] as `yyyy-MM-dd`. Leaves the field unchanged if cancelled.
Future<void> pickDateOfBirth(
  BuildContext context,
  TextEditingController controller,
) async {
  final now = DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime.tryParse(controller.text) ?? DateTime(now.year - 20),
    firstDate: DateTime(1900),
    lastDate: now,
  );
  if (picked == null) return;
  controller.text = DateFormat('yyyy-MM-dd').format(picked);
}
