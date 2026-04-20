import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../generated/l10n.dart';
import '../../../../constants/app_font_size.dart';
import '../../../../constants/routes.dart';
import '../../../../network/dio_client.dart';
import '../../../../network/clients/users_api_client.dart';
import '../../../../session/session_provider.dart';

final currentUserProfileProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final session = ref.watch(sessionProvider);
  final userId = session.userId;
  if (userId == null) {
    return null;
  }

  final users = await UsersApiClient(DioClient.main).getAllUsers();
  for (final user in users.cast<Map<String, dynamic>>()) {
    if (user['user_id']?.toString() == userId) {
      return user;
    }
  }

  return {
    'email': session.email,
    'role': session.role,
  };
});

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
            final firstName = profile?['first_name']?.toString() ?? '';
            final lastName = profile?['last_name']?.toString() ?? '';
            final email = profile?['email']?.toString() ?? '';
            final phone = profile?['phone']?.toString() ?? '';
            final dateOfBirth =
                _formatDate(profile?['date_of_birth']?.toString());
            return Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: height / 6.6),
                Center(
                  child: Text(
                    S.of(context).profileInformation,
                    style: GoogleFonts.patrickHand(
                      fontSize: height * AppFontSize.m,
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
                      SizedBox(height: height / 30),
                    ],
                  ),
                ),
                SizedBox(height: height / 30),
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
        enabled: false,
        initialValue: value,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.patrickHand(
          color: const Color(0xFF3A3329),
          fontSize: height / 40,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          labelText: label,
          contentPadding:
              EdgeInsets.symmetric(horizontal: height / 50, vertical: height / 90),
          labelStyle: GoogleFonts.patrickHand(
            color: const Color(0xFF7B5A3D),
            fontSize: height / 52,
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

  String _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    return raw.split(' ').first.split('T').first;
  }
}
