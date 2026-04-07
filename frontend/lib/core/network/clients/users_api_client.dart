import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'users_api_client.g.dart';

@RestApi()
abstract class UsersApiClient {
  factory UsersApiClient(Dio dio, {String? baseUrl}) = _UsersApiClient;

  @GET('/users/')
  Future<List<dynamic>> getAllUsers();

  @GET('/users/preferences')
  Future<List<dynamic>> getAllUsersWithPreferences();

  @DELETE('/users/{userId}')
  Future<void> deleteUser(@Path('userId') String userId);
}
