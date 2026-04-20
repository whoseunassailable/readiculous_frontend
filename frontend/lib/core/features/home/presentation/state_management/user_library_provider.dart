import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readiculous_frontend/core/cache/app_cache_service.dart';
import 'package:readiculous_frontend/core/features/home/data/datasources/home_remote_data_source.dart';
import 'package:readiculous_frontend/core/features/home/data/repositories/home_repository_impl.dart';
import 'package:readiculous_frontend/core/features/home/domain/entities/library.dart';

final userLibraryProvider =
    FutureProvider.autoDispose.family<Library?, String>((ref, userId) async {
  final cached = await AppCacheService.instance.getCurrentUserLibrary();
  if (cached != null) {
    final cachedUserProfile =
        await AppCacheService.instance.getCurrentUserProfile();
    if (cachedUserProfile?['user_id']?.toString() == userId) {
      return Library(
        libraryId: (cached['library_id'] as num?)?.toInt() ?? 0,
        name: cached['name']?.toString() ?? '',
        location: cached['location']?.toString(),
        verified: (cached['verified'] as num?)?.toInt(),
      );
    }
  }

  final repo = HomeRepositoryImpl(HomeRemoteDataSourceImpl());
  final library = await repo.getUserLibrary(userId);
  if (library != null) {
    await AppCacheService.instance.saveCurrentUserLibrary({
      'library_id': library.libraryId,
      'name': library.name,
      'location': library.location,
      'verified': library.verified,
    });
  }
  return library;
});
