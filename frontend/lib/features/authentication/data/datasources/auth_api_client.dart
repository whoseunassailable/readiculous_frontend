import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../dtos/login_request_dto.dart';
import '../dtos/login_response_dto.dart';
import '../dtos/register_request_dto.dart';
import '../dtos/register_response_dto.dart';

part 'auth_api_client.g.dart';

@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String? baseUrl}) = _AuthApiClient;

  @POST('/users/login')
  Future<LoginResponseDto> login(@Body() LoginRequestDto body);

  @POST('/users/create')
  Future<RegisterResponseDto> register(@Body() RegisterRequestDto body);
}
