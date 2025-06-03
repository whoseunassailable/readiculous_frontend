import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readiculous_frontend/core/features/authentication/presentation/register_page.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_font_size.dart';
import '../../../constants/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/display_snackbar.dart';
import '../../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _apiService = ApiService();

  final listOfImages = [
    "ask_ai_logo.png",
    "ask_ai_logo_1.png",
    "background_sign_up_page.png",
    "background_sign_up_page_2.png",
    "home_page.png",
    "login_or_sign_up.png",
    "logo_ask_ai.png",
    "logo_with_words.png",
    "register_page.png",
    "search_image_home_page.png",
    "splash_screen.png",
    "splash_screen_2.png",
    "splash_screen_3.png",
    "splash_screen_4.png",
  ];

  @override
  void dispose() {
    // Dispose controllers when not in use
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    // 4 looks nice
    // 7 is okayish
    // 8 is better than 7
    // 10 needs to be adjusted
    // 11 aesthetically look nice tbh
    // 13 is better
    return Scaffold(
      backgroundColor: AppColors.darkYellow,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text(
            //   AppLocalizations.of(context).yourJourneyToFindPerfectUniversity,
            //   style: const TextStyle(
            //       fontSize: 16,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.white),
            //   textAlign: TextAlign.center,
            // ),
            // Image.asset("assets/images/splash_screen.png"),
            Image.asset(
              height: height * 0.125,
              "assets/images/app_logo_3.png",
            ),
            // Image.asset(
            //   height: height * 0.125,
            //   "assets/images/app_logo_4.png",
            // ),
            SizedBox(height: height / 25),
            Column(
              children: [
                Text(
                  AppLocalizations.of(context).welcomeBack,
                  style: TextStyle(
                      fontSize: height * AppFontSize.m, color: Colors.black),
                ),
                Text(
                  AppLocalizations.of(context).loginToYourAccount,
                  style: TextStyle(
                    fontSize: height * AppFontSize.xxs,
                    fontStyle: FontStyle.italic,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: height / 25),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  labelText: AppLocalizations.of(context).email,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            SizedBox(height: height / 40),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                labelText: AppLocalizations.of(context).password,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              obscureText: true,
            ),
            SizedBox(height: height / 40),
            GestureDetector(
              onTap: () {
                // Handle forgot password
              },
              child: Text(
                AppLocalizations.of(context).forgotPassword,
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(height: height / 40),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text;
                final password = passwordController.text;
                print("username : $email");
                print("password : $password");

                // Call returns a Map on success, or null on failure
                final loginData = await _apiService.loginStudent(
                  email: email,
                  password: password,
                );
                print("loginData : $loginData");

                // if (loginData != null && loginData.containsKey('user_id')) {
                final userMap = loginData!['user'] as Map<String, dynamic>;
                final userId = userMap['user_id'].toString();
                print(userId);
                // Persist user_id, email, (and password if you really need it)
                final prefs = await SharedPreferences.getInstance();

                prefs.setString('userId', userId);
                await prefs.setString('email', email);

                // Navigate on success
                context.pushNamed(RouteNames.homePage);
                // } else {
                //   // Show error
                //   final displaySnackbar = DisplaySnackbar();
                //   displaySnackbar.showErrorWithoutFocus(
                //     context: context,
                //     message: AppLocalizations.of(context).loginFailed,
                //   );
                // }
              },
              child: Text(AppLocalizations.of(context).login),
            ),
            SizedBox(height: height / 80),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const RegisterPage()), // Directly pushing the page widget
                );
              },
              child: Text(AppLocalizations.of(context).signUp),
            ),
          ],
        ),
      ),
    );
  }
}
