import 'package:dio/dio.dart';

import '../suggested_books/domain/user_specific_genre_model.dart';
import '../suggested_books/domain/add_user_genre.dart';
import '../suggested_books/domain/get_all_user_preferences.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:5000/api', // For Android Emulator
    ),
  );

  // Flask/Python back-end on port 6000
  final Dio _flask = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:6000',
  ));

  // Create a user
  Future<Response> createUser({required Map<String, dynamic> data}) async {
    try {
      Response response = await _dio.post('/users/create', data: data);
      return response;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      Response response = await _dio.get('/users/preferences');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch user preferences: $e');
    }
  }

  Future<Map<String, dynamic>> getBookRecommendations(
      Map<String, dynamic> data) async {
    try {
      Response response = await _flask.post('/suggest', data: data);
      return response.data;
    } catch (e) {
      throw Exception('Failed to get book recommendations: $e');
    }
  }

  Future<Map<String, dynamic>?> loginStudent({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/users/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        return response.data;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<UserSpecificGenreModel>> getUserGenres(String userId) async {
    try {
      final Response response = await _dio.get('/user-genres/$userId');
      return List<UserSpecificGenreModel>.from(
        (response.data as List<dynamic>).map((json) =>
            UserSpecificGenreModel.fromJson(json as Map<String, dynamic>)),
      );
    } catch (e) {
      throw Exception('Failed to load user genres: $e');
    }
  }

  Future<Map<int, String>> getAllGenres() async {
    try {
      final response = await _dio.get('/genres');
      final List<dynamic> data = response.data;
      return {
        for (var genre in data)
          genre['genre_id'] as int: genre['name'] as String,
      };
    } catch (e) {
      print('Error fetching genres: $e');
      throw Exception('Failed to fetch genres');
    }
  }

  Future<GetAllUserPreferences> fetchAllUserPreferences() async {
    try {
      final response = await _dio.get('/user/preferences');
      return GetAllUserPreferences.fromJson(
          response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load user preferences: $e');
    }
  }

  Future<List<dynamic>> recommendBooksForUser(List<String> genres,
      {int topN = 10}) async {
    final resp = await _flask.post(
      '/recommend',
      data: {'genres': genres, 'top_n': topN},
    );
    return resp.data as List<dynamic>;
  }

  Future<Response> updateStudent({
    required String userId,
    required CreateUserGenreModel createUserGenreModel,
  }) async {
    try {
      if (createUserGenreModel.genreIds!.isEmpty) {
        throw Exception('No fields to update');
      }
      Response response = await _dio.post(
        '/user-genres',
        data: createUserGenreModel,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<Response> deleteUser(String userId) async {
    try {
      Response response = await _dio.delete('/users/$userId');
      return response;
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<List<dynamic>> getAllUsers() async {
    try {
      final response = await _dio.get('/users');
      return response.data;
    } catch (e) {
      return [
        {'error': e.toString()}
      ];
    }
  }

  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      return response.data;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateUser(
      String userId, Map<String, dynamic> updatedData) async {
    try {
      final response = await _dio.put('/users/$userId', data: updatedData);
      return response.data;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createWishlistItem(
      Map<String, dynamic> wishlistData) async {
    try {
      final response = await _dio.post('/wishlist', data: wishlistData);
      return response.data;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<List<dynamic>> getAllWishlistItems() async {
    try {
      final response = await _dio.get('/wishlist');
      return response.data;
    } catch (e) {
      return [
        {'error': e.toString()}
      ];
    }
  }

  Future<List<dynamic>> getWishlistByUserId(String userId) async {
    try {
      final response = await _dio.get('/wishlist/user/$userId');
      return response.data;
    } catch (e) {
      return [
        {'error': e.toString()}
      ];
    }
  }

  Future<Map<String, dynamic>> updateWishlistItem(
      String wishlistId, Map<String, dynamic> updatedData) async {
    try {
      final response =
          await _dio.put('/wishlist/$wishlistId', data: updatedData);
      return response.data;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteWishlistItem(String wishlistId) async {
    try {
      final response = await _dio.delete('/wishlist/$wishlistId');
      return response.data;
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}