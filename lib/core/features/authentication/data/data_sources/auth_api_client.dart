import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api_client.g.dart';

@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String? baseUrl}) = _AuthApiClient;

  @POST('/users/login')
  Future<Map<String, dynamic>> login(@Body() Map<String, dynamic> body);

  @POST('/users/create')
  Future<Map<String, dynamic>> register(@Body() Map<String, dynamic> body);
}
