import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../../../../../generated/l10n.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_font_size.dart';
import '../../../../constants/app_roles.dart';
import '../../../../session/session_provider.dart';
import '../../../../utils/animated_text.dart';
import '../../../../utils/custom_text_form_field.dart';
import '../../../../utils/display_snackbar.dart';
import '../../../../utils/regex_patterns.dart';
import '../../../../widgets/minimalistic_button.dart';
import '../../data/data_sources/auth_remote_ds.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/user_model.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
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
  String _role = AppRoles.user;
  final uuid = const Uuid();
  final logger = Logger(printer: PrettyPrinter(colors: true));
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
        textMessage: S.of(context).welcomeMessage,
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/login_page.png'),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Back button row ──
              Padding(
                padding: EdgeInsets.only(left: width / 20, top: height * 0.01),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child:
                        const Icon(MaterialCommunityIcons.arrow_left, size: 28),
                  ),
                ),
              ),
              SizedBox(height: height * 0.01),
              // ── Logo centered ──
              Image.asset('assets/images/logo.png', height: height * 0.10),
              SizedBox(height: height * 0.015),
              // ── Title ──
              Text(
                animatedWelcomeMessage,
                style: TextStyle(
                    fontSize: width * AppFontSize.xxxl,
                    fontWeight: FontWeight.w500,
                    color: AppColors.blackColor),
              ),
              SizedBox(height: height * 0.02),
              // ── Scrollable form fields ──
              Expanded(
                child: SingleChildScrollView(
                  child: listOfTextFormFields(height: height, width: width),
                ),
              ),
              // ── Sign Up button pinned at bottom ──
              Padding(
                padding: EdgeInsets.symmetric(vertical: height * 0.02),
                child: SizedBox(
                  height: height * 0.075,
                  child: MinimalistButton(
                    onPressed: () async {
                      final authRepo =
                          AuthRepositoryImpl(AuthRemoteDataSource());

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
                          message: S.of(context).pleaseEnterValidEmail,
                          focusNode: emailFocus,
                        );
                        return;
                      }

                      if (!isNameValid) {
                        displaySnackbar.showErrorWithFocus(
                          context: context,
                          message: S.of(context).pleaseEnterValidName,
                          focusNode: nameFocus,
                        );
                        return;
                      }

                      if (!isDobValid) {
                        displaySnackbar.showErrorWithFocus(
                          context: context,
                          message: S.of(context).pleaseEnterValidDOB,
                          focusNode: dobFocus,
                        );
                        return;
                      }

                      if (!isPhoneValid) {
                        displaySnackbar.showErrorWithFocus(
                          context: context,
                          message: S.of(context).pleaseEnterValidPhoneNumber,
                          focusNode: phoneNumberFocus,
                        );
                        return;
                      }

                      if (!isLocationValid) {
                        displaySnackbar.showErrorWithFocus(
                          context: context,
                          message: S.of(context).pleaseEnterValidLocation,
                          focusNode: locationFocus,
                        );
                        return;
                      }

                      if (!isPasswordValid) {
                        displaySnackbar.showErrorWithFocus(
                          context: context,
                          message: S.of(context).pleaseEnterValidPassword,
                          focusNode: passwordFocus,
                        );
                        return;
                      }

                      if (!validPassword) {
                        displaySnackbar.showErrorWithFocus(
                          context: context,
                          message: S
                              .of(context)
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

                      final payload = UserModel(
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        phone: phone,
                        dateOfBirth: dob,
                        password: password,
                        location: location,
                        role: _role,
                      ).toJson();

                      final result = await authRepo.register(payload);

                      if (result.isSuccess) {
                        final data = result.data!;

                        String? userId;
                        if (data['user'] is Map) {
                          userId = (data['user']['user_id']).toString();
                        } else if (data['data'] is Map) {
                          final inner = data['data'] as Map<String, dynamic>;
                          userId =
                              (inner['user_id'] ?? inner['id'])?.toString();
                        }

                        await ref.read(sessionProvider.notifier).setSession(
                              userId: userId,
                              email: email,
                              role: _role,
                            );

                        if (!context.mounted) return;
                        context.go('/home_page');
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
                    text: S.of(context).signUp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget listOfTextFormFields({
    required double height,
    required double width,
  }) {
    final spacing = SizedBox(height: height * 0.012);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width / 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextFormField(
            hintText: S.of(context).email,
            controller: _emailController,
            prefixIcon: const Icon(MaterialCommunityIcons.email),
          ),
          spacing,
          CustomTextFormField(
            hintText: S.of(context).name,
            controller: _nameController,
            prefixIcon: const Icon(MaterialCommunityIcons.account),
          ),
          spacing,
          CustomTextFormField(
            hintText: S.of(context).dob,
            controller: _dobController,
            prefixIcon: const Icon(MaterialCommunityIcons.calendar),
          ),
          spacing,
          CustomTextFormField(
            hintText: S.of(context).phoneNumber,
            controller: _phoneController,
            prefixIcon: const Icon(MaterialCommunityIcons.phone),
          ),
          spacing,
          CustomTextFormField(
            hintText: S.of(context).location,
            controller: _locationController,
            prefixIcon: const Icon(Entypo.location),
          ),
          spacing,
          // "Are you a librarian?" role selector
          DropdownButtonFormField<String>(
            value: _role,
            decoration: const InputDecoration(
              prefixIcon: Icon(MaterialCommunityIcons.account_tie),
              hintText: 'Are you a librarian?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
            items: const [
              DropdownMenuItem(value: 'user', child: Text('No')),
              DropdownMenuItem(value: 'librarian', child: Text('Yes')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _role = value);
            },
          ),
          spacing,
          CustomTextFormField(
            hintText: S.of(context).password,
            controller: _passwordController,
            prefixIcon: const Icon(MaterialCommunityIcons.lock),
            obscureText: true,
          ),
          spacing,
          CustomTextFormField(
            hintText: S.of(context).confirmPassword,
            controller: _confirmPasswordController,
            prefixIcon: const Icon(MaterialCommunityIcons.lock_check),
            obscureText: true,
          ),
          spacing,
        ],
      ),
    );
  }
}
