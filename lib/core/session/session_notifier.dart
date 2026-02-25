// lib/core/session/session_notifier.dart
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'session_state.dart';

class SessionNotifier extends Notifier<SessionState> {
  static const _kRoleKey = 'role';
  static const _kEmailKey = 'email';
  static const _kUserIdKey = 'user_id';
  static const _kTokenKey = 'token';

  @override
  SessionState build() {
    // initial synchronous state
    // we'll load prefs via init() from provider file
    return const SessionState();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      role: prefs.getString(_kRoleKey),
      email: prefs.getString(_kEmailKey),
      userId: prefs.getString(_kUserIdKey),
      token: prefs.getString(_kTokenKey),
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
      await prefs.setString(_kRoleKey, email);
    }
    state = state.copyWith(email: email);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRoleKey);
    await prefs.remove(_kUserIdKey);
    await prefs.remove(_kTokenKey);

    state = const SessionState(initialized: true);
  }
}
