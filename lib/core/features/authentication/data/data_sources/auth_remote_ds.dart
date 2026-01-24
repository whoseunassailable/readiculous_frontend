import 'package:dio/dio.dart';

import '../../../../network/dio_client.dart';

class AuthRemoteDataSource {
  final Dio _dio = DioClient.main;

  Future<Response> register(Map<String, dynamic> data) {
    return _dio.post('/users/create', data: data);
  }

  Future<Response> login({
    required String email,
    required String password,
  }) {
    return _dio.post('/users/login', data: {
      'email': email,
      'password': password,
    });
  }
}
