// lib/core/session/session_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/cache/app_cache_service.dart';
import 'package:readiculous_frontend/core/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'session_state.dart';

class SessionNotifier extends Notifier<SessionState> {
  static const _kIsLoggedInKey = 'is_logged_in';
  static const _kRoleKey = 'role';
  static const _kEmailKey = 'email';
  static const _kUserIdKey = 'user_id';
  static const _kTokenKey = 'token';
  static const _kHasGenrePrefsKey = 'has_genre_prefs';

  /// Older builds cached the login password here in plain text. Nothing reads
  /// it any more; [init] deletes it from devices that still have it.
  static const _kLegacyPasswordKey = 'session_password';

  @override
  SessionState build() {
    return const SessionState();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    await prefs.remove(_kLegacyPasswordKey);
    final isLoggedIn = prefs.getBool(_kIsLoggedInKey) ?? false;
    final role = isLoggedIn ? prefs.getString(_kRoleKey) : null;
    final email = isLoggedIn ? prefs.getString(_kEmailKey) : null;
    final userId = isLoggedIn ? prefs.getString(_kUserIdKey) : null;
    final token = isLoggedIn ? prefs.getString(_kTokenKey) : null;
    final hasGenrePrefs = prefs.getBool(_kHasGenrePrefsKey);

    AppLogger.i(
      'Session init: isLoggedIn=$isLoggedIn userId=$userId role=$role '
      'email=$email hasGenrePrefs=$hasGenrePrefs '
      'rawKeys={isLoggedIn:${prefs.getBool(_kIsLoggedInKey)},'
      'userId:${prefs.getString(_kUserIdKey)},role:${prefs.getString(_kRoleKey)},'
      'email:${prefs.getString(_kEmailKey)}}',
    );

    state = state.copyWith(
      role: role,
      email: email,
      userId: userId,
      token: token,
      hasGenrePrefs: hasGenrePrefs,
      initialized: true,
    );
  }

  Future<void> setSession({
    String? role,
    String? email,
    String? userId,
    String? token,
    bool? hasGenrePrefs,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_kIsLoggedInKey, true);
    if (role != null) await prefs.setString(_kRoleKey, role);
    if (email != null) await prefs.setString(_kEmailKey, email);
    if (userId != null) await prefs.setString(_kUserIdKey, userId);
    if (token != null) await prefs.setString(_kTokenKey, token);
    if (hasGenrePrefs != null) {
      await prefs.setBool(_kHasGenrePrefsKey, hasGenrePrefs);
    }
    await prefs.reload();

    AppLogger.i(
      'Session saved: isLoggedIn=${prefs.getBool(_kIsLoggedInKey)} '
      'userId=${prefs.getString(_kUserIdKey)} role=${prefs.getString(_kRoleKey)} '
      'email=${prefs.getString(_kEmailKey)}',
    );

    // hasGenrePrefs is folded into this same state transition (rather than
    // set via a later, separate call) so the router never observes a
    // logged-in session with an unknown genre-prefs status — that
    // intermediate state was causing a premature redirect to onboarding.
    state = state.copyWith(
      role: role ?? state.role,
      email: email ?? state.email,
      userId: userId ?? state.userId,
      token: token ?? state.token,
      hasGenrePrefs: hasGenrePrefs ?? state.hasGenrePrefs,
      initialized: true,
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
      await prefs.setString(
          _kEmailKey, email); // fix: was incorrectly writing to _kRoleKey
    }
    state = state.copyWith(email: email);
  }

  Future<void> markGenrePrefsSet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHasGenrePrefsKey, true);
    state = state.copyWith(hasGenrePrefs: true);
  }

  Future<void> setGenrePrefsStatus(bool hasGenrePrefs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHasGenrePrefsKey, hasGenrePrefs);
    state = state.copyWith(hasGenrePrefs: hasGenrePrefs);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kIsLoggedInKey);
    await prefs.remove(_kRoleKey);
    await prefs.remove(_kEmailKey);
    await prefs.remove(_kUserIdKey);
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kHasGenrePrefsKey);
    await AppCacheService.instance.clearUserScopedCache();

    AppLogger.i('Session cleared');

    state = const SessionState(initialized: true);
  }
}
