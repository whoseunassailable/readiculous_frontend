import 'package:flutter/material.dart';

class UpdateInfoPage extends StatefulWidget {
  const UpdateInfoPage({Key? key}) : super(key: key);

  @override
  _UpdateInfoPageState createState() => _UpdateInfoPageState();
}

class _UpdateInfoPageState extends State<UpdateInfoPage> {
  // Controllers for TextFields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isEditing = false; // Flag to toggle between edit and view mode

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

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
            // First Name
            _buildTextField('First Name', firstNameController, isEditing),
            const SizedBox(height: 15),
            // Last Name
            _buildTextField('Last Name', lastNameController, isEditing),
            const SizedBox(height: 15),
            // Date of Birth
            _buildTextField('Date of Birth', dobController, isEditing),
            const SizedBox(height: 15),
            // Email
            _buildTextField('Email', emailController, isEditing),
            const SizedBox(height: 15),
            // Phone Number
            _buildTextField('Phone Number', phoneController, isEditing),
            const SizedBox(height: 30),
            // Action Buttons (Save Profile and Save/Cancel)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.orangeAccent, // Updated to backgroundColor
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }

  // Method to build a text field with a label
  Widget _buildTextField(
      String label, TextEditingController controller, bool editable) {
    return TextField(
      controller: controller,
      enabled: editable,
      style: const TextStyle(color: Colors.black), // Black text color
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black), // Black label text
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black), // Black border
        ),
        filled: true,
        fillColor: Colors.white, // White background for the text field
      ),
    );
  }

  // Enable the fields for editing
  void _enableEditing() {
    setState(() {
      isEditing = true;
    });
  }

  // Save profile changes
  void _saveProfile() {
    setState(() {
      isEditing = false;
    });
    // Save logic goes here (e.g., API call, database update)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  // Cancel editing and revert to view mode
  void _cancelEditing() {
    setState(() {
      isEditing = false;
    });
    // Optionally, reset fields to their initial values here
  }
}
