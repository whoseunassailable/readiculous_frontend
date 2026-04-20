import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/cache/app_cache_service.dart';
import 'package:readiculous_frontend/core/cache/app_cache_warmer.dart';
import 'package:readiculous_frontend/core/features/authentication/data/data_sources/auth_remote_ds.dart';
import 'package:readiculous_frontend/core/network/clients/user_genres_api_client.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/core/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionBootstrap {
  SessionBootstrap._();

  static const _kPasswordKey = 'session_password';
  static const _kEmailKey = 'email';

  static Future<void> restoreIfPossible(ProviderContainer container) async {
    final session = container.read(sessionProvider);
    if (session.userId != null && session.role != null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final email = prefs.getString(_kEmailKey);
    final password = prefs.getString(_kPasswordKey);

    if (email == null ||
        email.isEmpty ||
        password == null ||
        password.isEmpty) {
      AppLogger.i('Session bootstrap: no cached credentials available');
      return;
    }

    try {
      AppLogger.i('Session bootstrap: attempting silent login for $email');
      final payload =
          await AuthRemoteDataSource().login(email: email, password: password);
      final user = payload['user'];
      if (user is! Map<String, dynamic>) {
        AppLogger.w('Session bootstrap: invalid login payload');
        return;
      }

      final userId = user['user_id']?.toString();
      final role = user['role']?.toString();
      if (userId == null || userId.isEmpty || role == null || role.isEmpty) {
        AppLogger.w('Session bootstrap: missing session fields');
        return;
      }

      await container.read(sessionProvider.notifier).setSession(
            userId: userId,
            role: role,
            email: email,
            password: password,
          );

      await AppCacheService.instance.saveCurrentUserProfile(user);

      if (role == 'user') {
        try {
          final genres = await UserGenresApiClient(DioClient.main)
              .getUserGenrePreferences(userId);
          await container
              .read(sessionProvider.notifier)
              .setGenrePrefsStatus(genres.isNotEmpty);
        } catch (_) {
          await container
              .read(sessionProvider.notifier)
              .setGenrePrefsStatus(false);
        }
      }

      await AppCacheWarmer.warmForLoggedInUser(userId);
      AppLogger.i('Session bootstrap: silent login restored session');
    } catch (e, st) {
      AppLogger.e('Session bootstrap failed', error: e, stackTrace: st);
    }
  }
}
