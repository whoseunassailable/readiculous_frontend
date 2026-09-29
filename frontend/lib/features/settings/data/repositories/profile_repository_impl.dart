import 'package:dio/dio.dart';

import '../../../../core/cache/app_cache_service.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../dtos/change_password_request_dto.dart';
import '../dtos/update_profile_request_dto.dart';
import '../dtos/user_profile_dto.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;
  final AppCacheService cache;

  const ProfileRepositoryImpl(this.remote, this.cache);

  /// Server first; the cached copy is only used when the server can't be
  /// reached.
  @override
  Future<UserProfile> getProfile(String userId) async {
    try {
      final dto = await remote.fetchProfile(userId);
      await cache.saveCurrentUserProfile(dto.toJson());
      return dto.toEntity();
    } on DioException catch (e) {
      final cached = await _cachedProfile(userId);
      if (cached != null) return cached.toEntity();
      final error = ApiError.fromDio(e);
      AppLogger.e('getProfile failed (userId: $userId)', error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e('getProfile unexpected error (userId: $userId)',
          error: e, stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }

  @override
  Future<UserProfile> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String location,
    String? phone,
    String? dateOfBirth,
  }) async {
    try {
      final dto = await remote.updateProfile(
        userId,
        UpdateProfileRequestDto(
          firstName: firstName,
          lastName: lastName,
          email: email,
          location: location,
          phone: phone,
          dateOfBirth: dateOfBirth,
        ),
      );
      await cache.saveCurrentUserProfile(dto.toJson());
      return dto.toEntity();
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e('updateProfile failed (userId: $userId)', error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e('updateProfile unexpected error (userId: $userId)',
          error: e, stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }

  @override
  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remote.changePassword(
        userId,
        ChangePasswordRequestDto(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
      );
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e('changePassword failed (userId: $userId)', error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e('changePassword unexpected error (userId: $userId)',
          error: e, stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }

  /// The cached profile, if it belongs to [userId]. A missing, foreign or
  /// unreadable entry is a cache miss.
  Future<UserProfileDto?> _cachedProfile(String userId) async {
    try {
      final cached = await cache.getCurrentUserProfile();
      if (cached == null || cached['user_id'] != userId) return null;
      return UserProfileDto.fromJson(cached);
    } catch (e) {
      AppLogger.e('Ignoring unreadable profile cache', error: e);
      return null;
    }
  }
}
