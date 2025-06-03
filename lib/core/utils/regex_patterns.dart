class RegexPatterns {
  static final RegExp email = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final RegExp name = RegExp(r'^[a-zA-Z\s]{2,}$');
  static final RegExp dob = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  static final RegExp phone = RegExp(r'^\d{10}$');
  static final RegExp password = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
}
// UltraSafe@2025Pass
