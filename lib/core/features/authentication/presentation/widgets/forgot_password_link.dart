import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../generated/l10n.dart';

class ForgotPasswordLink extends StatelessWidget {
  const ForgotPasswordLink({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: handle forgot password
      },
      child: Text(
        S.of(context).forgotPassword,
        style: GoogleFonts.patrickHand(
          fontSize: 18,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
