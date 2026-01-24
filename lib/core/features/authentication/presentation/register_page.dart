import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_font_size.dart';
import '../../../constants/routes.dart';
import '../../../utils/animated_text.dart';
import '../../../utils/custom_text_form_field.dart';
import '../../../utils/display_snackbar.dart';
import '../../../utils/regex_patterns.dart';
import '../../../widgets/minimalistic_button.dart';
import '../data/data_sources/auth_remote_ds.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/student_model.dart';
import '../../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _logger = Logger(printer: PrettyPrinter(colors: true));

  // Declare controllers for each text form field
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final uuid = const Uuid();
  final logger = Logger(printer: PrettyPrinter(colors: true));
  final _apiService = ApiService();
  final AnimatedMessage animatedMessage = AnimatedMessage();
  String animatedWelcomeMessage = '';
  final emailFocus = FocusNode();
  final nameFocus = FocusNode();
  final dobFocus = FocusNode();
  final phoneNumberFocus = FocusNode();
  final locationFocus = FocusNode();
  final passwordFocus = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => animatedMessage.animatedWelcome(
        context: context,
        textMessage: AppLocalizations.of(context).welcomeMessage,
        onUpdate: (text) => setState(() => animatedWelcomeMessage = text),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers when not in use
    _emailController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.darkYellow,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/login_page.png'),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: width / 20),
                GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(MaterialCommunityIcons.arrow_left)),
                SizedBox(width: width / 5),
                Image.asset(
                  "assets/images/logo.png",
                  height: height / 4,
                ),
              ],
            ),
            Text(
              animatedWelcomeMessage,
              style: TextStyle(
                  fontSize: width * AppFontSize.xxxl,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blackColor),
            ),
            listOfTextFormFields(height: height, width: width),
            SizedBox(
              height: height * 0.075,
              child: MinimalistButton(
                onPressed: () async {
                  final authRepo = AuthRepositoryImpl(AuthRemoteDataSource());

                  final email = _emailController.text.trim();
                  final name = _nameController.text.trim();
                  final dob = _dobController.text.trim();
                  final location = _locationController.text.trim();
                  final phone = _phoneController.text.trim();
                  final password = _passwordController.text;
                  final confirmPassword = _confirmPasswordController.text;

                  final isEmailValid = RegexPatterns.email.hasMatch(email);
                  final isNameValid = RegexPatterns.name.hasMatch(name);
                  final isDobValid = RegexPatterns.dob.hasMatch(dob);
                  final isPhoneValid = RegexPatterns.phone.hasMatch(phone);
                  final isLocationValid =
                      location.isNotEmpty; // or RegexPatterns.location
                  final isPasswordValid =
                      RegexPatterns.password.hasMatch(password);
                  final validPassword = password == confirmPassword;

                  final displaySnackbar = DisplaySnackbar();

                  if (!isEmailValid) {
                    displaySnackbar.showErrorWithFocus(
                      context: context,
                      message:
                          AppLocalizations.of(context).pleaseEnterValidEmail,
                      focusNode: emailFocus,
                    );
                    return;
                  }

                  if (!isNameValid) {
                    displaySnackbar.showErrorWithFocus(
                      context: context,
                      message:
                          AppLocalizations.of(context).pleaseEnterValidName,
                      focusNode: nameFocus,
                    );
                    return;
                  }

                  if (!isDobValid) {
                    displaySnackbar.showErrorWithFocus(
                      context: context,
                      message: AppLocalizations.of(context).pleaseEnterValidDOB,
                      focusNode: dobFocus,
                    );
                    return;
                  }

                  if (!isPhoneValid) {
                    displaySnackbar.showErrorWithFocus(
                      context: context,
                      message: AppLocalizations.of(context)
                          .pleaseEnterValidPhoneNumber,
                      focusNode: phoneNumberFocus,
                    );
                    return;
                  }

                  if (!isLocationValid) {
                    displaySnackbar.showErrorWithFocus(
                      context: context,
                      message:
                          AppLocalizations.of(context).pleaseEnterValidLocation,
                      focusNode: locationFocus,
                    );
                    return;
                  }

                  if (!isPasswordValid) {
                    displaySnackbar.showErrorWithFocus(
                      context: context,
                      message:
                          AppLocalizations.of(context).pleaseEnterValidPassword,
                      focusNode: passwordFocus,
                    );
                    return;
                  }

                  if (!validPassword) {
                    displaySnackbar.showErrorWithFocus(
                      context: context,
                      message: AppLocalizations.of(context)
                          .passwordAndConfirmPasswordDoNotMatch,
                      focusNode: passwordFocus,
                    );
                    return;
                  }

                  // Split name safely
                  final parts = name
                      .split(RegExp(r'\s+'))
                      .where((p) => p.isNotEmpty)
                      .toList();
                  final firstName = parts.isNotEmpty ? parts.first : "";
                  final lastName =
                      parts.length > 1 ? parts.sublist(1).join(' ') : "";

                  final payload = StudentModel(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    phone: phone,
                    dateOfBirth: dob,
                    password: password, // use password (same as confirm)
                    location: location,
                  ).toJson();

                  final result = await authRepo.register(payload);

                  if (result.isSuccess) {
                    final data = result.data!;

                    String? userId;
                    if (data['user'] is Map) {
                      userId = (data['user']['user_id']).toString();
                    } else if (data['data'] is Map) {
                      final inner = data['data'] as Map<String, dynamic>;
                      userId = (inner['user_id'] ??
                              inner['student_id'] ??
                              inner['id'])
                          ?.toString();
                    }

                    final prefs = await SharedPreferences.getInstance();
                    if (userId != null) await prefs.setString('userId', userId);
                    await prefs.setString('email', email);

                    if (!context.mounted) return;
                    context.pushNamed(RouteNames.homePage);
                    return;
                  }

                  final err = result.error!;
                  _logger.e(
                      'Register failed: ${err.statusCode}\n${err.message}\n${err.details}');

                  if (!context.mounted) return;

                  displaySnackbar.showErrorWithFocus(
                    context: context,
                    message: err.message,
                    focusNode: emailFocus,
                  );
                },
                text: AppLocalizations.of(context).signUp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  listOfTextFormFields({
    required double height,
    required double width,
  }) {
    List<String> listOfTextFormFields = [
      AppLocalizations.of(context).email,
      AppLocalizations.of(context).name,
      AppLocalizations.of(context).dob,
      AppLocalizations.of(context).phoneNumber,
      AppLocalizations.of(context).location,
      AppLocalizations.of(context).password,
      AppLocalizations.of(context).confirmPassword,
    ];

    List<TextEditingController> listOfTextEditingControllers = [
      _emailController,
      _nameController,
      _dobController,
      _phoneController,
      _locationController,
      _passwordController,
      _confirmPasswordController
    ];

    List<bool> obscureTextList = [
      false, // Email (no obscuring)
      false, // Name (no obscuring)
      false, // DOB (no obscuring)
      false, // Phone Number (no obscuring)
      false, // Location
      true, // Password (obscured)
      true, // Confirm Password (obscured)
    ];

    const List<Icon> listOfIcons = [
      Icon(MaterialCommunityIcons.email), // Email
      Icon(MaterialCommunityIcons.account), // Name
      Icon(MaterialCommunityIcons.calendar), // Date of Birth (DOB)
      Icon(MaterialCommunityIcons.phone), // Phone Number
      Icon(Entypo.location),
      Icon(MaterialCommunityIcons.lock), // Password
      Icon(MaterialCommunityIcons.lock_check), // Confirm Password
    ];

    return SizedBox(
      height: height * 0.60,
      child: Padding(
        padding: EdgeInsets.fromLTRB(width / 15, 0, width / 15, 0),
        child: ListView.builder(
          itemCount: listOfTextFormFields.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                CustomTextFormField(
                  hintText: listOfTextFormFields[index],
                  controller: listOfTextEditingControllers[index],
                  prefixIcon: listOfIcons[index],
                  obscureText: obscureTextList[index],
                ),
                SizedBox(height: height * 0.015),
              ],
            );
          },
        ),
      ),
    );
  }
}
