import 'package:readiculous_frontend/core/cache/app_cache_service.dart';
import 'package:readiculous_frontend/core/features/home/data/datasources/home_api_client.dart';
import 'package:readiculous_frontend/core/network/clients/libraries_api_client.dart';
import 'package:readiculous_frontend/core/network/clients/users_api_client.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';

class AppCacheWarmer {
  AppCacheWarmer._();

  static Future<void> warmLibraries() async {
    final raw = await LibrariesApiClient(DioClient.main).getAllLibraries();
    final items = raw.cast<Map<String, dynamic>>().toList()
      ..sort((a, b) => (a['name']?.toString() ?? '')
          .toLowerCase()
          .compareTo((b['name']?.toString() ?? '').toLowerCase()));
    await AppCacheService.instance.saveLibraries(items);
  }

  static Future<void> warmCurrentUserProfile(String userId) async {
    final users = await UsersApiClient(DioClient.main).getAllUsers();
    for (final user in users.cast<Map<String, dynamic>>()) {
      if (user['user_id']?.toString() == userId) {
        await AppCacheService.instance.saveCurrentUserProfile(user);
        return;
      }
    }
  }

  static Future<void> warmCurrentUserLibrary(String userId) async {
    final response = await HomeApiClient(DioClient.main).getUserLibrary(userId);
    final library = response.library;

    await AppCacheService.instance.saveCurrentUserLibrary({
      'library_id': library.libraryId,
      'name': library.name,
      'location': library.location,
      'verified': library.verified,
    });
  }

  static Future<void> warmForLoggedInUser(String userId) async {
    await Future.wait([
      warmLibraries(),
      warmCurrentUserProfile(userId),
      warmCurrentUserLibrary(userId),
    ]);
  }
}
