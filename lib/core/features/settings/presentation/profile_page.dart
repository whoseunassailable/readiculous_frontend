import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../constants/routes.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false; // Flag to toggle between edit and view mode
  final _apiservice = ApiService();
  final _authservice = AuthService();

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
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFFAF2), // Set background color to #FFFAF2
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.orange, // Orange color for the profile bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            // Profile fields with data from SharedPreferences
            _buildTextField(firstName, isEditing),
            const SizedBox(height: 15),
            _buildTextField(lastName, isEditing),
            const SizedBox(height: 15),
            _buildTextField(dateOfBirth, isEditing),
            const SizedBox(height: 15),
            _buildTextField(email, isEditing),
            const SizedBox(height: 15),
            _buildTextField(phone, isEditing),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.pushNamed(RouteNames.homePage),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context).home),
                ),
                SizedBox(width: MediaQuery.of(context).size.width / 30),
                ElevatedButton(
                  onPressed: () async {
                    final sharedPreferences =
                        await SharedPreferences.getInstance();
                    final userId = sharedPreferences.getString('userId');
                    print('userID : ${userId}');
                    await _apiservice.deleteStudent(userId!);
                    _authservice.clearStudentDetails();
                    context.pushNamed(RouteNames.loginPage);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context).delete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Method to build a text field with a label and value
  Widget _buildTextField(String label, bool editable) {
    return TextField(
      enabled: editable,
      style: const TextStyle(color: Colors.black), // Black text color
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black), // Black label text
        hintStyle:
            const TextStyle(color: Colors.black54), // Grey placeholder text
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black), // Black border
        ),
        filled: true,
        fillColor: Colors.white, // White background for the text field
      ),
    );
  }
}
