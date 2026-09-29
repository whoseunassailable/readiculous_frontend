import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/appbar.dart';
import '../../../../core/utils/custom_text_form_field.dart';
import '../../../../core/utils/display_snackbar.dart';
import '../../../../core/utils/regex_patterns.dart';
import '../../../../core/widgets/minimalistic_button.dart';
import '../../../../generated/l10n.dart';
import '../state_management/change_password_controller.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  final _currentFocus = FocusNode();
  final _newFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    _currentFocus.dispose();
    _newFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  /// Changed → confirm and go back; failed (e.g. "Current password is
  /// incorrect") → show why and focus the current-password field.
  void _onChangeStateChanged(
      AsyncValue<void>? previous, AsyncValue<void> next) {
    next.whenOrNull(
      data: (_) {
        if (previous?.isLoading != true) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).passwordUpdated)),
        );
        context.pop();
      },
      error: (error, _) => DisplaySnackbar().showErrorWithFocus(
        context: context,
        message: error.toString(),
        focusNode: _currentFocus,
      ),
    );
  }

  void _onChangePressed() {
    if (ref.read(changePasswordControllerProvider).isLoading) return;

    final current = _currentController.text;
    final next = _newController.text;
    final s = S.of(context);

    // Same password rule as registration.
    final checks = [
      (current.isNotEmpty, s.pleaseEnterCurrentPassword, _currentFocus),
      (
        RegexPatterns.password.hasMatch(next),
        s.pleaseEnterValidPassword,
        _newFocus
      ),
      (next != current, s.newPasswordMustBeDifferent, _newFocus),
      (
        _confirmController.text == next,
        s.passwordAndConfirmPasswordDoNotMatch,
        _confirmFocus
      ),
    ];
    for (final (isValid, message, focusNode) in checks) {
      if (!isValid) {
        DisplaySnackbar().showErrorWithFocus(
          context: context,
          message: message,
          focusNode: focusNode,
        );
        return;
      }
    }

    ref
        .read(changePasswordControllerProvider.notifier)
        .change(currentPassword: current, newPassword: next);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      changePasswordControllerProvider,
      _onChangeStateChanged,
    );
    final isSaving = ref.watch(
      changePasswordControllerProvider.select((s) => s.isLoading),
    );

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final s = S.of(context);
    final spacing = SizedBox(height: height * 0.015);

    return Scaffold(
      appBar: StylishAppBar(title: s.changePassword),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/login_page.png'),
          ),
        ),
        child: SafeArea(
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
                        hintText: s.currentPassword,
                        focusNode: _currentFocus,
                        controller: _currentController,
                        obscureText: true,
                        prefixIcon: const Icon(MaterialCommunityIcons.lock),
                      ),
                      spacing,
                      CustomTextFormField(
                        showLabel: true,
                        hintText: s.newPassword,
                        focusNode: _newFocus,
                        controller: _newController,
                        obscureText: true,
                        prefixIcon:
                            const Icon(MaterialCommunityIcons.lock_reset),
                      ),
                      spacing,
                      CustomTextFormField(
                        showLabel: true,
                        hintText: s.confirmNewPassword,
                        focusNode: _confirmFocus,
                        controller: _confirmController,
                        obscureText: true,
                        prefixIcon:
                            const Icon(MaterialCommunityIcons.lock_check),
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
                    onPressed: _onChangePressed,
                    isLoading: isSaving,
                    text: s.changePassword,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
