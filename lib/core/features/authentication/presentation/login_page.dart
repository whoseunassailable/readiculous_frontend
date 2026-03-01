import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:readiculous_frontend/core/features/authentication/presentation/register_page.dart';
import '../../../../generated/l10n.dart';
import 'package:readiculous_frontend/core/theme/crayon/crayon_button.dart';
import 'package:readiculous_frontend/core/theme/crayon/crayon_text_field.dart';
import 'package:readiculous_frontend/core/theme/crayon/crayon_styles.dart';

import '../../../session/session_provider.dart';
import '../data/data_sources/auth_remote_ds.dart';
import '../data/repositories/auth_repository_impl.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _logger = Logger(printer: PrettyPrinter(colors: true));

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Keep ONLY your existing logo (no second logo)
                Image.asset(
                  "assets/images/logo.png",
                  height: height * 0.30,
                ),
                Text(
                  S.of(context).welcomeBack,
                  style: CrayonStyles.title(height),
                  textAlign: TextAlign.center,
                ),
                Text(
                  S.of(context).loginToYourAccount,
                  style: CrayonStyles.subtitle(height),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height / 70),
                CrayonTextField(
                  controller: emailController,
                  hint: S.of(context).email,
                ),
                SizedBox(height: height / 70),
                CrayonTextField(
                  controller: passwordController,
                  hint: S.of(context).password,
                  obscureText: true,
                ),
                SizedBox(height: height / 35),
                GestureDetector(
                  onTap: () {
                    // Handle forgot password
                  },
                  child: Text(
                    S.of(context).forgotPassword,
                    style: GoogleFonts.patrickHand(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: height / 70),
                CrayonButton(
                  label: S.of(context).login,
                  fill: Colors.white.withOpacity(0.92),
                  textColor: const Color(
                      0xFF6A5ACD), // soft purple-ish like screenshot
                  onPressed: () async {
                    final _authRepo =
                        AuthRepositoryImpl(AuthRemoteDataSource());

                    final email = emailController.text.trim();
                    final password = passwordController.text;

                    final result = await _authRepo.login(
                      email: email,
                      password: password,
                    );

                    if (result.isSuccess) {
                      final data = result.data!;
                      final userMap = data['user'] as Map<String, dynamic>;
                      final userId = userMap['user_id'].toString();
                      final role = userMap['role'].toString();

                      // ✅ update in-memory session state
                      await ref.read(sessionProvider.notifier).setSession(
                            userId: userId,
                            role: role,
                            email:
                                email, // only if your SessionState supports email
                          );

                      // Now navigation works (router sees loggedIn=true)
                      if (!context.mounted) return;
                      context.go('/home_page'); // or pushNamed if you prefer
                    }

                    // Failure path
                    final err = result.error!;
                    _logger
                        .e('Login failed: ${err.statusCode} \n${err.message}');

                    if (!context.mounted) return;

                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(content: Text(err.message)),
                    // );
                  },
                ),
                SizedBox(height: height / 70),
                CrayonButton(
                  label: S.of(context).signUp,
                  fill: Colors.white.withOpacity(0.92),
                  textColor: const Color(0xFF6A5ACD),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
