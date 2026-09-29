import 'package:dio/dio.dart';

import '../../../../core/cache/app_cache_service.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../dtos/login_request_dto.dart';
import '../dtos/register_request_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AppCacheService cache;

  const AuthRepositoryImpl(this.remote, this.cache);

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await remote.login(
        LoginRequestDto(email: email, password: password),
      );
      await cache.saveCurrentUserProfile(dto.toJson());
      return dto.toEntity();
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e('login failed', error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e('login unexpected error', error: e, stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }

  @override
  Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String dateOfBirth,
    required String password,
    required String location,
    required String role,
  }) async {
    try {
      final dto = await remote.register(
        RegisterRequestDto(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          dateOfBirth: dateOfBirth,
          password: password,
          location: location,
          role: role,
        ),
      );
      return dto.toEntity();
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e('register failed', error: error);
      throw error;
    } catch (e, st) {
      AppLogger.e('register unexpected error', error: e, stackTrace: st);
      throw ApiError(message: 'Unexpected error', details: e.toString());
    }
  }
}
