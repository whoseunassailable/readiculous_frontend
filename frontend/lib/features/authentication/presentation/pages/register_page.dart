import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../generated/l10n.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_font_size.dart';
import '../../../../core/constants/app_roles.dart';
import '../../../../core/utils/animated_text.dart';
import '../../../../core/utils/custom_text_form_field.dart';
import '../../../../core/utils/display_snackbar.dart';
import '../../../../core/utils/regex_patterns.dart';
import '../../../../core/widgets/minimalistic_button.dart';
import '../state_management/register_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  // Declare controllers for each text form field
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _role = AppRoles.user;
  final AnimatedMessage animatedMessage = AnimatedMessage();
  String animatedWelcomeMessage = '';
  final emailFocus = FocusNode();
  final firstNameFocus = FocusNode();
  final lastNameFocus = FocusNode();
  final dobFocus = FocusNode();
  final phoneNumberFocus = FocusNode();
  final locationFocus = FocusNode();
  final passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => animatedMessage.animatedWelcome(
        context: context,
        textMessage: S.of(context).welcomeMessage,
        onUpdate: (text) {
          if (mounted) setState(() => animatedWelcomeMessage = text);
        },
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers when not in use
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    emailFocus.dispose();
    firstNameFocus.dispose();
    lastNameFocus.dispose();
    dobFocus.dispose();
    phoneNumberFocus.dispose();
    locationFocus.dispose();
    passwordFocus.dispose();

    super.dispose();
  }

  /// Reacts to state changes from [RegisterController]:
  ///   • AsyncData  → navigate to home (the router redirects new readers on
  ///     to genre onboarding)
  ///   • AsyncError → show the error and focus the email field
  void _onRegisterStateChanged(
      AsyncValue<void>? previous, AsyncValue<void> next) {
    next.whenOrNull(
      data: (_) => context.go('/home_page'),
      error: (error, _) => DisplaySnackbar().showErrorWithFocus(
        context: context,
        message: error.toString(),
        focusNode: emailFocus,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    ref.listen<AsyncValue<void>>(
      registerControllerProvider,
      _onRegisterStateChanged,
    );
    final isSubmitting = ref.watch(
      registerControllerProvider.select((s) => s.isLoading),
    );

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
                    onPressed: _onSignUpPressed,
                    isLoading: isSubmitting,
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

  void _onSignUpPressed() {
    if (ref.read(registerControllerProvider).isLoading) return;

    final email = _emailController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final dob = _dobController.text.trim();
    final location = _locationController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final isEmailValid = RegexPatterns.email.hasMatch(email);
    final isFirstNameValid = RegexPatterns.name.hasMatch(firstName);
    final isLastNameValid = RegexPatterns.name.hasMatch(lastName);
    final isDobValid = dob.isNotEmpty;
    final isPhoneValid = RegexPatterns.phone.hasMatch(phone);
    final isLocationValid = location.isNotEmpty; // or RegexPatterns.location
    final isPasswordValid = RegexPatterns.password.hasMatch(password);
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

    if (!isFirstNameValid) {
      displaySnackbar.showErrorWithFocus(
        context: context,
        message: S.of(context).pleaseEnterValidName,
        focusNode: firstNameFocus,
      );
      return;
    }

    if (!isLastNameValid) {
      displaySnackbar.showErrorWithFocus(
        context: context,
        message: S.of(context).pleaseEnterValidName,
        focusNode: lastNameFocus,
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
        message: S.of(context).passwordAndConfirmPasswordDoNotMatch,
        focusNode: passwordFocus,
      );
      return;
    }

    ref.read(registerControllerProvider.notifier).register(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          dateOfBirth: dob,
          password: password,
          location: location,
          role: _role,
        );
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final current = DateTime.tryParse(_dobController.text);
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;
    _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
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
            focusNode: emailFocus,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(MaterialCommunityIcons.email),
          ),
          spacing,
          CustomTextFormField(
            hintText: S.of(context).firstName,
            focusNode: firstNameFocus,
            controller: _firstNameController,
            prefixIcon: const Icon(MaterialCommunityIcons.account),
          ),
          spacing,
          CustomTextFormField(
            hintText: S.of(context).lastName,
            focusNode: lastNameFocus,
            controller: _lastNameController,
            prefixIcon: const Icon(MaterialCommunityIcons.account),
          ),
          spacing,
          CustomTextFormField(
            hintText: S.of(context).dob,
            focusNode: dobFocus,
            controller: _dobController,
            readOnly: true,
            onTap: _pickDateOfBirth,
            prefixIcon: const Icon(MaterialCommunityIcons.calendar),
          ),
          spacing,
          CustomTextFormField(
            hintText: S.of(context).phoneNumber,
            focusNode: phoneNumberFocus,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(MaterialCommunityIcons.phone),
          ),
          spacing,
          CustomTextFormField(
            hintText: S.of(context).location,
            focusNode: locationFocus,
            controller: _locationController,
            prefixIcon: const Icon(Entypo.location),
          ),
          spacing,
          // "Are you a librarian?" role selector
          DropdownButtonFormField<String>(
            initialValue: _role,
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
            focusNode: passwordFocus,
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
