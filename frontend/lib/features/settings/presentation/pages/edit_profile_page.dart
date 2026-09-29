import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/appbar.dart';
import '../../../../core/utils/custom_text_form_field.dart';
import '../../../../core/utils/date_of_birth_picker.dart';
import '../../../../core/utils/display_snackbar.dart';
import '../../../../core/utils/regex_patterns.dart';
import '../../../../core/widgets/minimalistic_button.dart';
import '../../../../generated/l10n.dart';
import '../../domain/entities/user_profile.dart';
import '../state_management/edit_profile_controller.dart';
import '../state_management/profile_providers.dart';

class EditProfilePage extends ConsumerWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: StylishAppBar(title: S.of(context).editProfile),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/login_page.png'),
          ),
        ),
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load profile.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (profile) => profile == null
              ? const SizedBox.shrink()
              : _EditProfileForm(profile: profile),
        ),
      ),
    );
  }
}

class _EditProfileForm extends ConsumerStatefulWidget {
  final UserProfile profile;

  const _EditProfileForm({required this.profile});

  @override
  ConsumerState<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<_EditProfileForm> {
  late final _firstNameController =
      TextEditingController(text: widget.profile.firstName);
  late final _lastNameController =
      TextEditingController(text: widget.profile.lastName);
  late final _emailController =
      TextEditingController(text: widget.profile.email);
  late final _phoneController =
      TextEditingController(text: widget.profile.phone ?? '');
  late final _dobController =
      TextEditingController(text: widget.profile.dateOfBirth ?? '');
  late final _locationController =
      TextEditingController(text: widget.profile.location);

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _locationFocus = FocusNode();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _locationController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _locationFocus.dispose();
    super.dispose();
  }

  /// Saved → confirm and go back; failed → show why (e.g. "Email already
  /// exists") and focus the email field.
  void _onSaveStateChanged(AsyncValue<void>? previous, AsyncValue<void> next) {
    next.whenOrNull(
      data: (_) {
        if (previous?.isLoading != true) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).profileUpdated)),
        );
        context.pop();
      },
      error: (error, _) => DisplaySnackbar().showErrorWithFocus(
        context: context,
        message: error.toString(),
        focusNode: _emailFocus,
      ),
    );
  }

  void _onSavePressed() {
    if (ref.read(editProfileControllerProvider).isLoading) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final location = _locationController.text.trim();
    final s = S.of(context);
    final snackbar = DisplaySnackbar();

    // Required fields match the NOT NULL columns of the users table; phone
    // and date of birth are optional.
    final checks = [
      (
        RegexPatterns.name.hasMatch(firstName),
        s.pleaseEnterValidName,
        _firstNameFocus
      ),
      (
        RegexPatterns.name.hasMatch(lastName),
        s.pleaseEnterValidName,
        _lastNameFocus
      ),
      (
        RegexPatterns.email.hasMatch(email),
        s.pleaseEnterValidEmail,
        _emailFocus
      ),
      (
        phone.isEmpty || RegexPatterns.phone.hasMatch(phone),
        s.pleaseEnterValidPhoneNumber,
        _phoneFocus
      ),
      (location.isNotEmpty, s.pleaseEnterValidLocation, _locationFocus),
    ];
    for (final (isValid, message, focusNode) in checks) {
      if (!isValid) {
        snackbar.showErrorWithFocus(
          context: context,
          message: message,
          focusNode: focusNode,
        );
        return;
      }
    }

    ref.read(editProfileControllerProvider.notifier).save(
          firstName: firstName,
          lastName: lastName,
          email: email,
          location: location,
          phone: phone.isEmpty ? null : phone,
          dateOfBirth: _dobController.text.isEmpty ? null : _dobController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      editProfileControllerProvider,
      _onSaveStateChanged,
    );
    final isSaving = ref.watch(
      editProfileControllerProvider.select((s) => s.isLoading),
    );

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final s = S.of(context);
    final spacing = SizedBox(height: height * 0.015);

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: width / 15,
                vertical: height * 0.03,
              ),
              child: Column(
                children: [
                  CustomTextFormField(
                    showLabel: true,
                    hintText: s.firstName,
                    focusNode: _firstNameFocus,
                    controller: _firstNameController,
                    prefixIcon: const Icon(MaterialCommunityIcons.account),
                  ),
                  spacing,
                  CustomTextFormField(
                    showLabel: true,
                    hintText: s.lastName,
                    focusNode: _lastNameFocus,
                    controller: _lastNameController,
                    prefixIcon: const Icon(MaterialCommunityIcons.account),
                  ),
                  spacing,
                  CustomTextFormField(
                    showLabel: true,
                    hintText: s.email,
                    focusNode: _emailFocus,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(MaterialCommunityIcons.email),
                  ),
                  spacing,
                  CustomTextFormField(
                    showLabel: true,
                    hintText: s.phoneNumber,
                    focusNode: _phoneFocus,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(MaterialCommunityIcons.phone),
                  ),
                  spacing,
                  CustomTextFormField(
                    showLabel: true,
                    hintText: s.dob,
                    controller: _dobController,
                    readOnly: true,
                    onTap: () => pickDateOfBirth(context, _dobController),
                    prefixIcon: const Icon(MaterialCommunityIcons.calendar),
                  ),
                  spacing,
                  CustomTextFormField(
                    showLabel: true,
                    hintText: s.location,
                    focusNode: _locationFocus,
                    controller: _locationController,
                    prefixIcon: const Icon(Entypo.location),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: height * 0.02),
            child: SizedBox(
              height: height * 0.075,
              child: MinimalistButton(
                onPressed: _onSavePressed,
                isLoading: isSaving,
                text: s.save,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
