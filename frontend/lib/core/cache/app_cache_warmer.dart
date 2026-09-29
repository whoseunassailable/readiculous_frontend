import 'package:readiculous_frontend/core/cache/app_cache_service.dart';
import 'package:readiculous_frontend/core/utils/app_logger.dart';
import 'package:readiculous_frontend/features/home/data/datasources/home_api_client.dart';
import 'package:readiculous_frontend/core/network/clients/libraries_api_client.dart';
import 'package:readiculous_frontend/core/network/clients/users_api_client.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';

/// Prefetches data into [AppCacheService]. Warm-up is best-effort: callers
/// fire it without awaiting, so failures are logged here instead of thrown.
class AppCacheWarmer {
  AppCacheWarmer._();

  static Future<void> warmLibraries() async {
    try {
      await _warmLibraries();
    } catch (e, st) {
      AppLogger.e('Library cache warm-up failed', error: e, stackTrace: st);
    }
  }

  static Future<void> warmForLoggedInUser(String userId) async {
    try {
      await Future.wait([
        _warmLibraries(),
        _warmCurrentUserProfile(userId),
        _warmCurrentUserLibrary(userId),
      ]);
    } catch (e, st) {
      AppLogger.e('Cache warm-up failed (userId: $userId)',
          error: e, stackTrace: st);
    }
  }

  static Future<void> _warmLibraries() async {
    final raw = await LibrariesApiClient(DioClient.main).getAllLibraries();
    final items = raw.cast<Map<String, dynamic>>().toList()
      ..sort((a, b) => (a['name']?.toString() ?? '')
          .toLowerCase()
          .compareTo((b['name']?.toString() ?? '').toLowerCase()));
    await AppCacheService.instance.saveLibraries(items);
  }

  static Future<void> _warmCurrentUserProfile(String userId) async {
    final users = await UsersApiClient(DioClient.main).getAllUsers();
    for (final user in users.cast<Map<String, dynamic>>()) {
      if (user['user_id']?.toString() == userId) {
        await AppCacheService.instance.saveCurrentUserProfile(user);
        return;
      }
    }
  }

  static Future<void> _warmCurrentUserLibrary(String userId) async {
    final response = await HomeApiClient(DioClient.main).getUserLibrary(userId);
    final library = response.library;

    await AppCacheService.instance.saveCurrentUserLibrary({
      'library_id': library.libraryId,
      'name': library.name,
      'location': library.location,
      'verified': library.verified,
    });
  }
}
