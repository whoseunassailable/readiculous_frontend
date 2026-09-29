import '../../../../core/network/dio_client.dart';
import '../dtos/login_request_dto.dart';
import '../dtos/register_request_dto.dart';
import '../dtos/user_dto.dart';
import 'auth_api_client.dart';

abstract class AuthRemoteDataSource {
  Future<UserDto> login(LoginRequestDto request);
  Future<UserDto> register(RegisterRequestDto request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthApiClient _client = AuthApiClient(DioClient.main);

  @override
  Future<UserDto> login(LoginRequestDto request) async {
    final response = await _client.login(request);
    return response.user;
  }

  @override
  Future<UserDto> register(RegisterRequestDto request) async {
    final response = await _client.register(request);
    return response.user;
  }
}
