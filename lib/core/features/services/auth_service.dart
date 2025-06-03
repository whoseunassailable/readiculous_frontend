import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Save student details
  Future<void> saveStudentDetails({
    required String studentId,
    required String firstName,
    required String lastName,
    required String email,
    int? greScore,
    int? toeflScore,
    String? preferredLocation,
    required String phone,
    required String dateOfBirth, // Changed to String
    required String password, // New field
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Save all the student details, handling nullable values
    await prefs.setString('student_id', studentId);
    await prefs.setString('first_name', firstName);
    await prefs.setString('last_name', lastName);
    await prefs.setString('email', email);
    await prefs.setInt(
        'gre_score', greScore ?? -1); // Using -1 to represent null
    await prefs.setInt(
        'toefl_score', toeflScore ?? -1); // Using -1 to represent null
    await prefs.setString('preferred_location', preferredLocation ?? '');
    await prefs.setString('phone', phone);
    await prefs.setString(
        'date_of_birth', dateOfBirth); // Save dateOfBirth as String
    await prefs.setString('password', password); // Save password
  }

  // Get student details
  Future<Map<String, dynamic>> getStudentDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String studentId = prefs.getString('student_id') ?? '';
    String firstName = prefs.getString('first_name') ?? '';
    String lastName = prefs.getString('last_name') ?? '';
    String email = prefs.getString('email') ?? '';
    int? greScore =
        prefs.getInt('gre_score') == -1 ? null : prefs.getInt('gre_score');
    int? toeflScore =
        prefs.getInt('toefl_score') == -1 ? null : prefs.getInt('toefl_score');
    String? preferredLocation = prefs.getString('preferred_location')!.isEmpty
        ? null
        : prefs.getString('preferred_location');
    String phone = prefs.getString('phone') ?? '';
    String dateOfBirth = prefs.getString('date_of_birth') ??
        ''; // Retrieve dateOfBirth as String
    String password = prefs.getString('password') ?? ''; // Retrieve password

    return {
      'student_id': studentId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'gre_score': greScore,
      'toefl_score': toeflScore,
      'preferred_location': preferredLocation,
      'phone': phone,
      'date_of_birth': dateOfBirth, // Return dateOfBirth as String
      'password': password, // Add password to the returned map
    };
  }

  // Check if the student details exist
  Future<bool> isStudentDetailsSaved() async {
    final prefs = await SharedPreferences.getInstance();
    String? firstName = prefs.getString('first_name');
    String? lastName = prefs.getString('last_name');
    return firstName != null && lastName != null;
  }

  // Update student details
  Future<void> updateStudentDetails({
    required int studentId,
    String? firstName,
    String? lastName,
    String? email,
    int? greScore,
    int? toeflScore,
    String? preferredLocation,
    String? phone,
    String? dateOfBirth, // Changed to String
    String? password, // New field
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Update only the non-null fields
    if (firstName != null) await prefs.setString('first_name', firstName);
    if (lastName != null) await prefs.setString('last_name', lastName);
    if (email != null) await prefs.setString('email', email);
    if (greScore != null) await prefs.setInt('gre_score', greScore);
    if (toeflScore != null) await prefs.setInt('toefl_score', toeflScore);
    if (preferredLocation != null)
      await prefs.setString('preferred_location', preferredLocation);
    if (phone != null) await prefs.setString('phone', phone);
    if (dateOfBirth != null)
      await prefs.setString(
          'date_of_birth', dateOfBirth); // Update dateOfBirth as String
    if (password != null)
      await prefs.setString('password', password); // Update password
  }

  // Clear student details (logout)
  Future<void> clearStudentDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('student_id');
    await prefs.remove('first_name');
    await prefs.remove('last_name');
    await prefs.remove('email');
    await prefs.remove('gre_score');
    await prefs.remove('toefl_score');
    await prefs.remove('preferred_location');
    await prefs.remove('phone');
    await prefs.remove('date_of_birth');
    await prefs.remove('password'); // Clear password
  }
}
