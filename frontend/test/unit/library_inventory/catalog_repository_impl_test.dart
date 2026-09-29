import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readiculous_frontend/core/network/api_error.dart';
import 'package:readiculous_frontend/features/library_inventory/data/datasources/catalog_remote_data_source.dart';
import 'package:readiculous_frontend/features/library_inventory/data/dtos/catalog_book_dto.dart';
import 'package:readiculous_frontend/features/library_inventory/data/repositories/catalog_repository_impl.dart';

class _FakeRemote implements CatalogRemoteDataSource {
  Object? error;
  final calls = <String>[];

  @override
  Future<List<CatalogBookDto>> searchBooks(String query, int limit) async {
    calls.add('$query/$limit');
    if (error != null) throw error!;
    return [
      CatalogBookDto.fromJson({
        'book_id': 69923,
        'title': 'Dune',
        'author': 'Frank Herbert',
        'cover_url': null,
        'isbn13': '9780441013593',
      }),
    ];
  }
}

void main() {
  test('CatalogBookDto parses a GET /books?search= row', () {
    final book =
        CatalogBookDto.fromJson({'book_id': 7, 'title': 'Emma', 'author': null})
            .toEntity();

    expect(book.bookId, 7);
    expect(book.title, 'Emma');
    expect(book.author, isNull);
  });

  test('searches the server with a limit and maps to entities', () async {
    final remote = _FakeRemote();

    final books = await CatalogRepositoryImpl(remote).searchBooks('dune');

    expect(remote.calls, ['dune/20']);
    expect(books.single.title, 'Dune');
    expect(books.single.author, 'Frank Herbert');
  });

  test('a server error keeps its message', () async {
    final options = RequestOptions(path: '/books/');
    final remote = _FakeRemote()
      ..error = DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 400,
          data: {'message': 'limit must be an integer from 1 to 50'},
        ),
      );

    await expectLater(
      CatalogRepositoryImpl(remote).searchBooks('dune'),
      throwsA(isA<ApiError>().having((e) => e.message, 'message',
          'limit must be an integer from 1 to 50')),
    );
  });
}
