import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readiculous_frontend/core/features/authentication/presentation/pages/login_page.dart';
import 'package:readiculous_frontend/core/features/authentication/presentation/state_management/login_controller.dart';
import 'package:readiculous_frontend/generated/l10n.dart';

// ── Fake controllers ──────────────────────────────────────────────────────────

/// Idles forever after login() is called — stays in AsyncLoading.
class _LoadingLoginController extends LoginController {
  @override
  FutureOr<void> build() {}

  @override
  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    // Never resolves — simulates a long-running request.
  }
}

/// Immediately returns an error when login() is called.
class _ErrorLoginController extends LoginController {
  @override
  FutureOr<void> build() {}

  @override
  Future<void> login({required String email, required String password}) async {
    state = AsyncError('Invalid credentials', StackTrace.current);
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _defaultApp() => ProviderScope(
      child: MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: const LoginPage(),
      ),
    );

Widget _appWithController<C extends LoginController>(C Function() create) =>
    ProviderScope(
      overrides: [loginControllerProvider.overrideWith(create)],
      child: MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: const LoginPage(),
      ),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    // Prevent GoogleFonts from making network requests during tests.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('LoginPage widget', () {
    testWidgets('renders two input fields and two action buttons', (tester) async {
      await tester.pumpWidget(_defaultApp());
      await tester.pumpAndSettle();

      // Email + password fields
      expect(find.byType(TextField), findsNWidgets(2));
      // Login + Sign Up buttons
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('buttons are enabled in the idle state', (tester) async {
      await tester.pumpWidget(_defaultApp());
      await tester.pumpAndSettle();

      final buttons = tester.widgetList<ElevatedButton>(find.byType(ElevatedButton));
      for (final btn in buttons) {
        expect(btn.onPressed, isNotNull, reason: 'Button should be enabled when idle');
      }
    });

    testWidgets('both buttons are disabled while a login request is in flight', (tester) async {
      await tester.pumpWidget(
        _appWithController(_LoadingLoginController.new),
      );
      await tester.pumpAndSettle();

      // Enter credentials and tap login.
      await tester.enterText(find.byType(TextField).first, 'test@readiculous.com');
      await tester.enterText(find.byType(TextField).last, 'secret');
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pump(); // one frame — controller is now AsyncLoading

      final buttons = tester.widgetList<ElevatedButton>(find.byType(ElevatedButton));
      for (final btn in buttons) {
        expect(btn.onPressed, isNull, reason: 'Buttons must be disabled while loading');
      }
    });

    testWidgets('shows a SnackBar with the error message on login failure', (tester) async {
      await tester.pumpWidget(
        _appWithController(_ErrorLoginController.new),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'bad@email.com');
      await tester.enterText(find.byType(TextField).last, 'wrongpass');
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Invalid credentials'), findsWidgets);
    });

    testWidgets('buttons return to enabled state after error', (tester) async {
      await tester.pumpWidget(
        _appWithController(_ErrorLoginController.new),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'bad@email.com');
      await tester.enterText(find.byType(TextField).last, 'wrongpass');
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      // After error the controller is in AsyncError (not loading)
      final buttons = tester.widgetList<ElevatedButton>(find.byType(ElevatedButton));
      for (final btn in buttons) {
        expect(btn.onPressed, isNotNull, reason: 'Buttons should be re-enabled after an error');
      }
    });
  });
}
