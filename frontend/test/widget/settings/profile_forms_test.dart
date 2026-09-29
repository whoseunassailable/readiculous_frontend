import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/core/widgets/minimalistic_button.dart';
import 'package:readiculous_frontend/features/settings/domain/entities/user_profile.dart';
import 'package:readiculous_frontend/features/settings/presentation/pages/change_password_page.dart';
import 'package:readiculous_frontend/features/settings/presentation/pages/edit_profile_page.dart';
import 'package:readiculous_frontend/features/settings/presentation/state_management/change_password_controller.dart';
import 'package:readiculous_frontend/features/settings/presentation/state_management/edit_profile_controller.dart';
import 'package:readiculous_frontend/features/settings/presentation/state_management/profile_providers.dart';
import 'package:readiculous_frontend/generated/l10n.dart';

// ── Recording controllers ─────────────────────────────────────────────────────

class _RecordingEditProfile extends EditProfileController {
  Map<String, String?>? saved;

  @override
  FutureOr<void> build() {}

  @override
  Future<void> save({
    required String firstName,
    required String lastName,
    required String email,
    required String location,
    String? phone,
    String? dateOfBirth,
  }) async {
    saved = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'location': location,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
    };
  }
}

class _RecordingChangePassword extends ChangePasswordController {
  (String, String)? changed;

  @override
  FutureOr<void> build() {}

  @override
  Future<void> change({
    required String currentPassword,
    required String newPassword,
  }) async {
    changed = (currentPassword, newPassword);
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

const _ava = UserProfile(
  userId: 'u1',
  firstName: 'Ava',
  lastName: 'Martinez',
  email: 'ava@example.com',
  role: 'user',
  location: 'Chicago',
  phone: '3125550100',
  dateOfBirth: '1999-08-15',
);

Future<void> _pump(WidgetTester tester, Widget page, List overrides) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ProviderScope(
    overrides: [...overrides],
    child: MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: page,
    ),
  ));
  await tester.pumpAndSettle();
}

Finder _field(int index) => find.byType(TextFormField).at(index);

bool _hasFocus(WidgetTester tester, int index) => tester
    .widget<EditableText>(
        find.descendant(of: _field(index), matching: find.byType(EditableText)))
    .focusNode
    .hasFocus;

Future<void> _submit(WidgetTester tester) async {
  await tester.tap(find.byType(MinimalistButton));
  await tester.pump();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('EditProfilePage', () {
    // Field order on the page.
    const first = 0, last = 1, email = 2, phone = 3, location = 5;

    Future<_RecordingEditProfile> pumpEdit(WidgetTester tester) async {
      final controller = _RecordingEditProfile();
      await _pump(tester, const EditProfilePage(), [
        currentUserProfileProvider.overrideWith((ref) async => _ava),
        editProfileControllerProvider.overrideWith(() => controller),
      ]);
      return controller;
    }

    testWidgets('opens with the current profile filled in', (tester) async {
      await pumpEdit(tester);

      expect(find.text('Ava'), findsOneWidget);
      expect(find.text('Martinez'), findsOneWidget);
      expect(find.text('ava@example.com'), findsOneWidget);
      expect(find.text('3125550100'), findsOneWidget);
      expect(find.text('1999-08-15'), findsOneWidget);
      expect(find.text('Chicago'), findsOneWidget);
    });

    testWidgets('saves trimmed edits', (tester) async {
      final controller = await pumpEdit(tester);
      await tester.enterText(_field(last), '  Lopez ');
      await tester.enterText(_field(location), ' Evanston');

      await _submit(tester);

      expect(controller.saved, {
        'firstName': 'Ava',
        'lastName': 'Lopez',
        'email': 'ava@example.com',
        'location': 'Evanston',
        'phone': '3125550100',
        'dateOfBirth': '1999-08-15',
      });
    });

    testWidgets('phone is optional: an empty phone is sent as null',
        (tester) async {
      final controller = await pumpEdit(tester);
      await tester.enterText(_field(phone), '');

      await _submit(tester);

      expect(controller.saved?['phone'], isNull);
    });

    testWidgets('an invalid email is rejected and focused', (tester) async {
      final controller = await pumpEdit(tester);
      await tester.enterText(_field(email), 'not-an-email');

      await _submit(tester);

      expect(controller.saved, isNull);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(_hasFocus(tester, email), true);
    });

    testWidgets('a phone that is not 10 digits is rejected', (tester) async {
      final controller = await pumpEdit(tester);
      await tester.enterText(_field(phone), '12345');

      await _submit(tester);

      expect(controller.saved, isNull);
      expect(_hasFocus(tester, phone), true);
    });

    testWidgets('an empty first name is rejected', (tester) async {
      final controller = await pumpEdit(tester);
      await tester.enterText(_field(first), '');

      await _submit(tester);

      expect(controller.saved, isNull);
      expect(_hasFocus(tester, first), true);
    });
  });

  group('ChangePasswordPage', () {
    const current = 0, next = 1, confirm = 2;

    Future<_RecordingChangePassword> pumpChange(WidgetTester tester) async {
      final controller = _RecordingChangePassword();
      await _pump(tester, const ChangePasswordPage(), [
        changePasswordControllerProvider.overrideWith(() => controller),
      ]);
      return controller;
    }

    Future<void> fill(
        WidgetTester tester, String c, String n, String cf) async {
      await tester.enterText(_field(current), c);
      await tester.enterText(_field(next), n);
      await tester.enterText(_field(confirm), cf);
    }

    testWidgets('a valid change is submitted', (tester) async {
      final controller = await pumpChange(tester);
      await fill(tester, 'Old@1234', 'New@12345', 'New@12345');

      await _submit(tester);

      expect(controller.changed, ('Old@1234', 'New@12345'));
    });

    testWidgets('the current password is required', (tester) async {
      final controller = await pumpChange(tester);
      await fill(tester, '', 'New@12345', 'New@12345');

      await _submit(tester);

      expect(controller.changed, isNull);
      expect(_hasFocus(tester, current), true);
    });

    testWidgets('a weak new password is rejected', (tester) async {
      final controller = await pumpChange(tester);
      await fill(tester, 'Old@1234', 'weak', 'weak');

      await _submit(tester);

      expect(controller.changed, isNull);
      expect(_hasFocus(tester, next), true);
    });

    testWidgets('the new password must differ from the current one',
        (tester) async {
      final controller = await pumpChange(tester);
      await fill(tester, 'Same@1234', 'Same@1234', 'Same@1234');

      await _submit(tester);

      expect(controller.changed, isNull);
    });

    testWidgets('confirmation must match', (tester) async {
      final controller = await pumpChange(tester);
      await fill(tester, 'Old@1234', 'New@12345', 'New@54321');

      await _submit(tester);

      expect(controller.changed, isNull);
      expect(_hasFocus(tester, confirm), true);
    });
  });
}
