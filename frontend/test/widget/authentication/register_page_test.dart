import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/core/widgets/minimalistic_button.dart';
import 'package:readiculous_frontend/features/authentication/presentation/pages/register_page.dart';
import 'package:readiculous_frontend/features/authentication/presentation/state_management/register_controller.dart';
import 'package:readiculous_frontend/generated/l10n.dart';

// ── Fake controller ───────────────────────────────────────────────────────────

/// Records what the page submits instead of calling the backend.
class _RecordingRegisterController extends RegisterController {
  Map<String, String>? submitted;

  @override
  FutureOr<void> build() {}

  @override
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String dateOfBirth,
    required String password,
    required String location,
    required String role,
  }) async {
    submitted = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'password': password,
      'location': location,
      'role': role,
    };
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

// Field order on the page.
const _email = 0, _first = 1, _last = 2, _dob = 3, _phone = 4;
const _location = 5, _password = 6, _confirm = 7;

Finder _field(int index) => find.byType(TextFormField).at(index);

Future<_RecordingRegisterController> _pumpPage(WidgetTester tester) async {
  // Tall phone-shaped surface, slightly wider than a real phone: the test
  // font draws every glyph as a full square, so text runs wider than on
  // device.
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);

  final controller = _RecordingRegisterController();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [registerControllerProvider.overrideWith(() => controller)],
      child: MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: const RegisterPage(),
      ),
    ),
  );
  // Let the typewriter-style welcome text finish (one timer per character).
  await tester.pump(const Duration(seconds: 10));
  await tester.pumpAndSettle();
  return controller;
}

Future<void> _pickDefaultDate(WidgetTester tester) async {
  await tester.ensureVisible(_field(_dob));
  await tester.tap(_field(_dob));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> _fillValidForm(WidgetTester tester) async {
  await tester.enterText(_field(_email), 'ada@example.com');
  await tester.enterText(_field(_first), 'Ada');
  await tester.enterText(_field(_last), 'Lovelace');
  await _pickDefaultDate(tester);
  await tester.enterText(_field(_phone), '5551234567');
  await tester.enterText(_field(_location), 'London');
  await tester.enterText(_field(_password), 'Secret@123');
  await tester.enterText(_field(_confirm), 'Secret@123');
}

Future<void> _submit(WidgetTester tester) async {
  await tester.tap(find.byType(MinimalistButton));
  await tester.pump();
}

bool _hasFocus(WidgetTester tester, int index) => tester
    .widget<EditableText>(
        find.descendant(of: _field(index), matching: find.byType(EditableText)))
    .focusNode
    .hasFocus;

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('RegisterPage', () {
    testWidgets('has separate first and last name fields', (tester) async {
      await _pumpPage(tester);

      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);
      expect(find.text('Date of birth'), findsOneWidget);
    });

    testWidgets('date of birth comes from a calendar, not typing',
        (tester) async {
      await _pumpPage(tester);

      final dob = tester.widget<EditableText>(find.descendant(
          of: _field(_dob), matching: find.byType(EditableText)));
      expect(dob.readOnly, true);

      await tester.ensureVisible(_field(_dob));
      await tester.tap(_field(_dob));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      final year = DateTime.now().year - 20;
      expect(find.text('$year-01-01'), findsOneWidget);
    });

    testWidgets('a missing last name is rejected before any request',
        (tester) async {
      final controller = await _pumpPage(tester);
      await _fillValidForm(tester);
      await tester.enterText(_field(_last), '');

      await _submit(tester);

      expect(controller.submitted, isNull);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(_hasFocus(tester, _last), true);
    });

    testWidgets('a missing date of birth is rejected', (tester) async {
      final controller = await _pumpPage(tester);
      await tester.enterText(_field(_email), 'ada@example.com');
      await tester.enterText(_field(_first), 'Ada');
      await tester.enterText(_field(_last), 'Lovelace');

      await _submit(tester);

      expect(controller.submitted, isNull);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('mismatched passwords are rejected', (tester) async {
      final controller = await _pumpPage(tester);
      await _fillValidForm(tester);
      await tester.enterText(_field(_confirm), 'Different@123');

      await _submit(tester);

      expect(controller.submitted, isNull);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('a valid form submits every field', (tester) async {
      final controller = await _pumpPage(tester);
      await _fillValidForm(tester);

      await _submit(tester);

      final year = DateTime.now().year - 20;
      expect(controller.submitted, {
        'firstName': 'Ada',
        'lastName': 'Lovelace',
        'email': 'ada@example.com',
        'phone': '5551234567',
        'dateOfBirth': '$year-01-01',
        'password': 'Secret@123',
        'location': 'London',
        'role': 'user',
      });
    });
  });
}
