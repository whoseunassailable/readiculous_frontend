import 'package:dio/dio.dart';

import '../../../../network/api_error.dart';
import '../../../../network/api_result.dart';
import '../../domain/auth_repository.dart';
import '../data_sources/auth_remote_ds.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  @override
  Future<ApiResult<Map<String, dynamic>>> register(
      Map<String, dynamic> data) async {
    try {
      final res = await remote.register(data);
      return ApiResult.success(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResult.failure(ApiError.fromDio(e));
    } catch (e) {
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
      final res = await remote.login(email: email, password: password);
      return ApiResult.success(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResult.failure(ApiError.fromDio(e));
    } catch (e) {
      return ApiResult.failure(
          ApiError(message: 'Unexpected error', details: e.toString()));
    }
  }
}
