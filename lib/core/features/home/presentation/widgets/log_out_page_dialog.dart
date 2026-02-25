import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:readiculous_frontend/core/constants/app_font_size.dart';
import 'package:readiculous_frontend/core/features/services/auth_service.dart';

import '../../../../../generated/l10n.dart';
import '../../../../constants/routes.dart';

class LogOutPageDialog extends StatelessWidget {
  final double height;
  final double width;
  const LogOutPageDialog({
    super.key,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: height / 2,
        width: width * 0.8,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE4C2B2), Color(0xFFD6B1A0)],
            ),
            border: Border.all(color: Colors.brown),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white70,
                  border: Border.all(color: Colors.white70),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(MaterialCommunityIcons.message_question),
                    Text(
                      S.of(context).logOut,
                      style: TextStyle(fontSize: height * AppFontSize.ml),
                    ),
                    GestureDetector(
                      child: const Icon(
                        MaterialCommunityIcons.close_circle,
                      ),
                      onTap: () => context.pop(),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 2, color: Colors.brown),
              Column(
                children: [
                  SizedBox(height: height / 30),
                  Text(
                    S.of(context).areYouSureYouWantToLogOut,
                    style: TextStyle(fontSize: height * AppFontSize.xs),
                  ),
                  Text(
                    S.of(context).anyUnsavedChangesWillBeLost,
                    style: TextStyle(fontSize: height * AppFontSize.xxs),
                  ),
                  SizedBox(height: height / 30),
                  Container(
                    width: width * 0.7,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFE4C2B2), Color(0xFFD6B1A0)],
                      ),
                      border: Border.all(color: Colors.brown),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: height / 60),
                        customizedButton(
                            context: context,
                            text: S.of(context).editProfile.toUpperCase(),
                            outlined: true,
                            pageName: RouteNames.profilePage),
                        customizedButton(
                          context: context,
                          text: S.of(context).changePassword.toUpperCase(),
                          outlined: true,
                          pageName: RouteNames.homePage,
                        ),
                        customizedButton(
                          context: context,
                          text: S.of(context).logOut.toUpperCase(),
                          outlined: false,
                          pageName: RouteNames.loginPage,
                        ),
                        SizedBox(height: height / 60),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  customizedButton({
    required BuildContext context,
    required String text,
    required bool outlined,
    required String pageName,
  }) {
    return SizedBox(
      width: outlined ? width * 0.6 : width * 0.5,
      child: outlined
          ? OutlinedButton(
              onPressed: () => context.pushNamed(pageName),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: const BorderSide(
                  color: Colors.brown,
                  width: 2,
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.brown,
                  fontSize: height * AppFontSize.xxs,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: () async {
                final authService = AuthService();
                await authService.clearStudentDetails();
                context.pushNamed(pageName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: const BorderSide(
                  color: Colors.brown,
                  width: 2,
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: height * AppFontSize.xxs,
                ),
              ),
            ),
    );
  }
}
