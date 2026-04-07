import 'package:dio/dio.dart';

import '../../../../network/api_error.dart';
import '../../../../network/api_result.dart';
import '../../../../utils/app_logger.dart';
import '../../domain/auth_repository.dart';
import '../data_sources/auth_remote_ds.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  @override
  Future<ApiResult<Map<String, dynamic>>> register(
      Map<String, dynamic> data) async {
    try {
      final result = await remote.register(data);
      return ApiResult.success(result);
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e('register failed', error: error);
      return ApiResult.failure(error);
    } catch (e, st) {
      AppLogger.e('register unexpected error', error: e, stackTrace: st);
      return ApiResult.failure(
          ApiError(message: 'Unexpected error', details: e.toString()));
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remote.login(email: email, password: password);
      return ApiResult.success(result);
    } on DioException catch (e) {
      final error = ApiError.fromDio(e);
      AppLogger.e('login failed', error: error);
      return ApiResult.failure(error);
    } catch (e, st) {
      AppLogger.e('login unexpected error', error: e, stackTrace: st);
      return ApiResult.failure(
          ApiError(message: 'Unexpected error', details: e.toString()));
    }
  }
}
