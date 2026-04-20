import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../generated/l10n.dart';
import '../../../../constants/routes.dart';
import '../../../../session/session_provider.dart';

class LogOutPageDialog extends ConsumerWidget {
  final double height;
  final double width;
  const LogOutPageDialog({
    super.key,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: width * 0.85,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF3),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFD7C6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).logOut,
                    style: GoogleFonts.patrickHand(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3A3329),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC7C2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: const Icon(Icons.close, size: 18, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Message
            Text(
              S.of(context).areYouSureYouWantToLogOut,
              textAlign: TextAlign.center,
              style: GoogleFonts.patrickHand(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3A3329),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              S.of(context).anyUnsavedChangesWillBeLost,
              textAlign: TextAlign.center,
              style: GoogleFonts.patrickHand(
                fontSize: 14,
                color: const Color(0xFF3A3329).withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 24),
            // Buttons
            _DialogButton(
              label: S.of(context).editProfile.toUpperCase(),
              color: const Color(0xFFB7D8FF),
              onTap: () {
                context.pop();
                context.pushNamed(RouteNames.profilePage);
              },
            ),
            const SizedBox(height: 10),
            _DialogButton(
              label: S.of(context).changePassword.toUpperCase(),
              color: const Color(0xFFFFE4A0),
              onTap: () {
                context.pop();
                context.pushNamed(RouteNames.homePage);
              },
            ),
            const SizedBox(height: 10),
            _DialogButton(
              label: S.of(context).logOut.toUpperCase(),
              color: const Color(0xFFFFC7C2),
              onTap: () async {
                await ref.read(sessionProvider.notifier).clearSession();
                if (!context.mounted) return;
                Navigator.of(context).pop();
                context.goNamed(RouteNames.loginPage);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.patrickHand(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3A3329),
            ),
          ),
        ),
      ),
    );
  }
}