import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../generated/l10n.dart';
import '../../../../core/constants/routes.dart';
import '../state_management/profile_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF2),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitHeight,
            image: AssetImage('assets/images/home.png'),
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
          data: (profile) {
            final firstName = profile?.firstName ?? '';
            final lastName = profile?.lastName ?? '';
            final email = profile?.email ?? '';
            final phone = profile?.phone ?? '';
            final dateOfBirth = profile?.dateOfBirth ?? '';
            final location = profile?.location ?? '';
            // Scrolls so the actions stay reachable on short screens.
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: height / 30),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: height / 6.6),
                  Center(
                    child: Text(
                      S.of(context).profileInformation,
                      style: GoogleFonts.patrickHand(
                        fontSize: height * 0.033,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3A3329),
                      ),
                    ),
                  ),
                  SizedBox(height: height / 20),
                  CircleAvatar(
                    backgroundImage:
                        const AssetImage('assets/icons/girl_avatar.png'),
                    radius: height / 12,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image:
                            AssetImage('assets/images/container_for_books.png'),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(height: height / 30),
                        _buildField(
                          label: 'First name',
                          value: firstName,
                          height: height,
                        ),
                        _buildField(
                          label: 'Last name',
                          value: lastName,
                          height: height,
                        ),
                        _buildField(
                          label: 'Date of birth',
                          value: dateOfBirth,
                          height: height,
                        ),
                        _buildField(
                          label: 'Email',
                          value: email,
                          height: height,
                        ),
                        _buildField(
                          label: 'Phone',
                          value: phone,
                          height: height,
                        ),
                        _buildField(
                          label: 'Location',
                          value: location,
                          height: height,
                        ),
                        SizedBox(height: height / 30),
                      ],
                    ),
                  ),
                  SizedBox(height: height / 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ActionButton(
                        label: S.of(context).editProfile,
                        onPressed: () =>
                            context.pushNamed(RouteNames.editProfile),
                      ),
                      const SizedBox(width: 12),
                      _ActionButton(
                        label: S.of(context).changePassword,
                        onPressed: () =>
                            context.pushNamed(RouteNames.changePassword),
                      ),
                    ],
                  ),
                  SizedBox(height: height / 80),
                  ElevatedButton(
                    onPressed: () => context.pushNamed(RouteNames.homePage),
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
                      S.of(context).home,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String value,
    required double height,
  }) {
    return Container(
      width: height / 3,
      padding: EdgeInsets.fromLTRB(height / 30, 0, height / 30, 0),
      margin: EdgeInsets.fromLTRB(
          height / 30, height / 80, height / 30, height / 80),
      child: TextFormField(
        // initialValue is only read when the field is created, so a new
        // value (after an edit) needs a new field.
        key: ValueKey('$label:$value'),
        enabled: false,
        initialValue: value,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.patrickHand(
          color: const Color(0xFF3A3329),
          fontSize: height / 52,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          labelText: label,
          contentPadding: EdgeInsets.symmetric(
              horizontal: height / 50, vertical: height / 90),
          labelStyle: GoogleFonts.patrickHand(
            color: const Color(0xFF7B5A3D),
            fontSize: height / 60,
            fontWeight: FontWeight.w700,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFB8743A), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFB8743A), width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFB8743A), width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFFFFFBF3),
          isDense: true,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFFBF3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: Color(0xFFB8743A), width: 2),
      ),
      child: Text(label, style: const TextStyle(color: Color(0xFF3A3329))),
    );
  }
}
