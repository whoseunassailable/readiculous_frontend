import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readiculous_frontend/core/network/api_error.dart';
import 'package:readiculous_frontend/shared/genres/data/datasources/genres_remote_data_source.dart';
import 'package:readiculous_frontend/shared/genres/data/dtos/genre_dto.dart';
import 'package:readiculous_frontend/shared/genres/data/repositories/genres_repository_impl.dart';

class _FakeRemote implements GenresRemoteDataSource {
  List<GenreDto> genres = [];
  Object? error;

  @override
  Future<List<GenreDto>> fetchUserGenres(String userId) async {
    if (error != null) throw error!;
    return genres;
  }
}

void main() {
  test('GenreDto parses GET /user-genres/:id rows', () {
    final genre =
        GenreDto.fromJson({'genre_id': 7, 'name': 'Fantasy'}).toEntity();
    expect(genre.genreId, 7);
    expect(genre.name, 'Fantasy');
  });

  test('getUserGenres maps DTOs to entities', () async {
    final remote = _FakeRemote()
      ..genres = const [
        GenreDto(genreId: 1, name: 'Fantasy'),
        GenreDto(genreId: 2, name: 'Mystery'),
      ];

    final genres = await GenresRepositoryImpl(remote).getUserGenres('u1');

    expect(genres.map((g) => g.name), ['Fantasy', 'Mystery']);
  });

  test('getUserGenres turns a DioException into an ApiError', () async {
    final options = RequestOptions(path: '/user-genres/u1');
    final remote = _FakeRemote()
      ..error = DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 500,
          data: {'message': 'Internal server error'},
        ),
      );

    await expectLater(
      GenresRepositoryImpl(remote).getUserGenres('u1'),
      throwsA(isA<ApiError>()
          .having((e) => e.message, 'message', 'Internal server error')),
    );
  });
}
