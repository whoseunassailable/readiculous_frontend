import '../../../../core/network/api_result.dart';

abstract class AuthRepository {
  Future<ApiResult<Map<String, dynamic>>> register(Map<String, dynamic> data);

  Future<ApiResult<Map<String, dynamic>>> login({
    required String email,
    required String password,
  });
}
