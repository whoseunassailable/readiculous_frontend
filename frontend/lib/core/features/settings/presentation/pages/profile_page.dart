import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readiculous_frontend/core/constants/app_font_size.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../generated/l10n.dart';
import '../../../../constants/routes.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  final apiService = ApiService();
  final authService = AuthService();

  // Profile information
  String firstName = '';
  String lastName = '';
  String email = '';
  String phone = '';
  String dateOfBirth = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      firstName = sharedPreferences.getString('first_name') ?? '';
      lastName = sharedPreferences.getString('last_name') ?? '';
      email = sharedPreferences.getString('email') ?? '';
      phone = sharedPreferences.getString('phone') ?? '';
      dateOfBirth = sharedPreferences.getString('date_of_birth') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFFAF2), // Set background color to #FFFAF2
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitHeight,
            image: AssetImage(
              'assets/images/home.png',
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: height / 6.6),
            Center(
              child: Text(
                S.of(context).profileInformation,
                style: TextStyle(
                  fontSize: height * AppFontSize.ml,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: height / 20),
            CircleAvatar(
              backgroundImage: AssetImage('assets/icons/girl_avatar.png'),
              radius: height / 12,
            ),
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/container_for_books.png',
                  ),
                  fit: BoxFit.fitHeight,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Profile fields with data from SharedPreferences
                  SizedBox(height: height / 30),

                  _buildTextField(firstName, isEditing, height),
                  _buildTextField(lastName, isEditing, height),
                  _buildTextField(dateOfBirth, isEditing, height),
                  _buildTextField(email, isEditing, height),
                  _buildTextField(phone, isEditing, height),
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
        ),
      ),
    );
  }

  Widget _buildTextField(String label, bool editable, double height) {
    return Container(
      width: height / 3,
      padding: EdgeInsets.fromLTRB(height / 30, 0, height / 30, 0),
      margin: EdgeInsets.fromLTRB(
          height / 30, height / 80, height / 30, height / 80),
      child: TextField(
        enabled: editable,
        textAlignVertical:
            TextAlignVertical.center, // This centers the text vertically
        style: TextStyle(
          color: Colors.black,
          fontSize: 28,
        ),
        decoration: InputDecoration(
          labelText: label,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black),
          ),
          filled: true,
          fillColor: Colors.white,
          isDense: true, // This is key!
        ),
      ),
    );
  }
}
