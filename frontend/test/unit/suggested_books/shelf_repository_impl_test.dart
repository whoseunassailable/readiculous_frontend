import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readiculous_frontend/core/network/api_error.dart';
import 'package:readiculous_frontend/features/suggested_books/data/datasources/shelf_remote_data_source.dart';
import 'package:readiculous_frontend/features/suggested_books/data/dtos/idle_shelf_dto.dart';
import 'package:readiculous_frontend/features/suggested_books/data/repositories/shelf_repository_impl.dart';
import 'package:readiculous_frontend/features/suggested_books/domain/entities/idle_book.dart';

/// A response from GET /library-books/4/idle.
const _response = {
  'idle_days': 180,
  'total_titles': 99,
  'total_copies': 200,
  'books': [
    {
      'book_id': 30,
      'title': 'Batman: Inferno',
      'author': 'Alex Irvine',
      'copies_total': 5,
      'copies_available': 5,
      'last_activity': null,
    },
    {
      'book_id': 31,
      'title': 'The Wild Children',
      'author': null,
      'copies_total': 1,
      'copies_available': 1,
      'last_activity': '2026-01-12T10:00:00.000Z',
    },
  ],
};

class _FakeRemote implements ShelfRemoteDataSource {
  Object? error;
  final calls = <String>[];

  @override
  Future<IdleShelfDto> fetchIdleBooks(int libraryId) async {
    calls.add('idle $libraryId');
    if (error != null) throw error!;
    return IdleShelfDto.fromJson(_response);
  }

  @override
  Future<void> removeCopies(int libraryId, int bookId, int copies) async {
    if (error != null) throw error!;
    calls.add('remove $libraryId $bookId $copies');
  }
}

void main() {
  test('parses the idle shelf, keeping which library it is', () async {
    final shelf = await ShelfRepositoryImpl(_FakeRemote()).getIdleBooks(4);

    expect(shelf.libraryId, 4);
    expect(
        (shelf.idleDays, shelf.totalTitles, shelf.totalCopies), (180, 99, 200));
    expect(shelf.books.first.title, 'Batman: Inferno');
    expect(shelf.books.first.lastActivity, isNull);
    expect(shelf.books.last.lastActivity, DateTime.utc(2026, 1, 12, 10));
  });

  group('IdleBook', () {
    IdleBook book(int copies) =>
        IdleBook(bookId: 1, title: 'Book', copiesTotal: copies);

    test('keeps one copy and frees the rest', () {
      expect(book(5).copiesToFree, 4);
      expect(book(5).removesTitle, false);
      expect(book(2).copiesToFree, 1);
    });

    test('an only copy is removed, taking the title out of stock', () {
      expect(book(1).copiesToFree, 1);
      expect(book(1).removesTitle, true);
    });
  });

  test('removing copies reaches the data source', () async {
    final remote = _FakeRemote();
    await ShelfRepositoryImpl(remote).removeCopies(4, 30, 4);
    expect(remote.calls, ['remove 4 30 4']);
    expect(const RemoveCopiesRequestDto(copies: 4).toJson(), {'copies': 4});
  });

  test('a refusal keeps the backend message', () async {
    final options = RequestOptions(path: '/library-books/4/30/remove');
    final remote = _FakeRemote()
      ..error = DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 409,
          data: {'message': 'Only copies on the shelf can be removed'},
        ),
      );

    await expectLater(
      ShelfRepositoryImpl(remote).removeCopies(4, 30, 9),
      throwsA(isA<ApiError>().having((e) => e.message, 'message',
          'Only copies on the shelf can be removed')),
    );
  });
}
