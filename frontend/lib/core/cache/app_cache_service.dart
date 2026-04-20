import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppCacheService {
  AppCacheService._();

  static const _librariesKey = 'cache_libraries';
  static const _currentUserProfileKey = 'cache_current_user_profile';
  static const _currentUserLibraryKey = 'cache_current_user_library';

  static final AppCacheService instance = AppCacheService._();

  Future<void> saveLibraries(List<Map<String, dynamic>> libraries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_librariesKey, jsonEncode(libraries));
  }

  Future<List<Map<String, dynamic>>?> getLibraries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_librariesKey);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! List) return null;
    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> saveCurrentUserProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserProfileKey, jsonEncode(profile));
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_currentUserProfileKey);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return Map<String, dynamic>.from(decoded);
  }

  Future<void> saveCurrentUserLibrary(Map<String, dynamic> library) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserLibraryKey, jsonEncode(library));
  }

  Future<Map<String, dynamic>?> getCurrentUserLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_currentUserLibraryKey);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return Map<String, dynamic>.from(decoded);
  }

  Future<void> clearUserScopedCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserProfileKey);
    await prefs.remove(_currentUserLibraryKey);
  }
}
