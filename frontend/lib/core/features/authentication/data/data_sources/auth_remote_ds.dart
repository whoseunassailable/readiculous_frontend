import '../../../../network/dio_client.dart';
import 'auth_api_client.dart';

class AuthRemoteDataSource {
  final AuthApiClient _client = AuthApiClient(DioClient.main);

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) =>
      _client.register(data);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) =>
      _client.login({'email': email, 'password': password});
}
