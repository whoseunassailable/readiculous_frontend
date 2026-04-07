// lib/core/session/session_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'session_state.dart';

class SessionNotifier extends Notifier<SessionState> {
  static const _kRoleKey = 'role';
  static const _kEmailKey = 'email';
  static const _kUserIdKey = 'user_id';
  static const _kTokenKey = 'token';
  static const _kHasGenrePrefsKey = 'has_genre_prefs';

  @override
  SessionState build() {
    return const SessionState();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      role: prefs.getString(_kRoleKey),
      email: prefs.getString(_kEmailKey),
      userId: prefs.getString(_kUserIdKey),
      token: prefs.getString(_kTokenKey),
      hasGenrePrefs: prefs.getBool(_kHasGenrePrefsKey),
      initialized: true,
    );
  }

  Future<void> setSession({
    String? role,
    String? email,
    String? userId,
    String? token,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (role != null) await prefs.setString(_kRoleKey, role);
    if (email != null) await prefs.setString(_kEmailKey, email);
    if (userId != null) await prefs.setString(_kUserIdKey, userId);
    if (token != null) await prefs.setString(_kTokenKey, token);

    state = state.copyWith(
      role: role ?? state.role,
      email: email ?? state.email,
      userId: userId ?? state.userId,
      token: token ?? state.token,
    );
  }

  Future<void> setRole(String? role) async {
    final prefs = await SharedPreferences.getInstance();
    if (role == null) {
      await prefs.remove(_kRoleKey);
    } else {
      await prefs.setString(_kRoleKey, role);
    }
    state = state.copyWith(role: role);
  }

  Future<void> setEmail(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    if (email == null) {
      await prefs.remove(_kEmailKey);
    } else {
      await prefs.setString(_kEmailKey, email); // fix: was incorrectly writing to _kRoleKey
    }
    state = state.copyWith(email: email);
  }

  Future<void> markGenrePrefsSet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHasGenrePrefsKey, true);
    state = state.copyWith(hasGenrePrefs: true);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRoleKey);
    await prefs.remove(_kEmailKey);
    await prefs.remove(_kUserIdKey);
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kHasGenrePrefsKey);

    state = const SessionState(initialized: true);
  }
}
