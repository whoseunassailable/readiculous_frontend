// lib/core/features/authentication/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../generated/l10n.dart';
import 'package:readiculous_frontend/core/theme/crayon/crayon_button.dart';
import 'package:readiculous_frontend/core/theme/crayon/crayon_text_field.dart';
import 'package:readiculous_frontend/core/theme/crayon/crayon_styles.dart';
import '../state_management/login_controller.dart';
import '../widgets/forgot_password_link.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Listener callback ────────────────────────────────────────────────────

  /// Reacts to state changes from [LoginController]:
  ///   • AsyncData  → navigate to home
  ///   • AsyncError → show a snackbar with the error message
  void _onLoginStateChanged(AsyncValue<void>? previous, AsyncValue<void> next) {
    next.whenOrNull(
      data: (_) => context.go('/home_page'),
      error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      },
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  void _onLoginPressed() {
    ref.read(loginControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _onSignUpPressed() => context.push('/register_page');

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final s = S.of(context);

    // Listen for side-effects (navigation, snackbars) without rebuilding.
    ref.listen<AsyncValue<void>>(
      loginControllerProvider,
      _onLoginStateChanged,
    );

    // Watch only to drive the loading indicator on the button.
    final isLoading = ref.watch(
      loginControllerProvider.select((s) => s.isLoading),
    );

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/images/login_page.png'),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _Logo(height: height),
                _WelcomeText(height: height, s: s),
                SizedBox(height: height / 70),
                CrayonTextField(
                  controller: _emailController,
                  hint: s.email,
                ),
                SizedBox(height: height / 70),
                CrayonTextField(
                  controller: _passwordController,
                  hint: s.password,
                  obscureText: true,
                ),
                SizedBox(height: height / 35),
                const ForgotPasswordLink(),
                SizedBox(height: height / 70),
                CrayonButton(
                  label: s.login,
                  fill: Colors.white.withOpacity(0.92),
                  textColor: const Color(0xFF6A5ACD),
                  // Disable the button while a request is in flight.
                  onPressed: isLoading ? null : _onLoginPressed,
                ),
                SizedBox(height: height / 70),
                CrayonButton(
                  label: s.signUp,
                  fill: Colors.white.withOpacity(0.92),
                  textColor: const Color(0xFF6A5ACD),
                  onPressed: isLoading ? null : _onSignUpPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Private sub-widgets ──────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  final double height;
  const _Logo({required this.height});

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/logo.png', height: height * 0.30);
  }
}

class _WelcomeText extends StatelessWidget {
  final double height;
  final S s;
  const _WelcomeText({required this.height, required this.s});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          s.welcomeBack,
          style: CrayonStyles.title(height),
          textAlign: TextAlign.center,
        ),
        Text(
          s.loginToYourAccount,
          style: CrayonStyles.subtitle(height),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
