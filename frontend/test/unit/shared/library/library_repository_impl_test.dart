import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readiculous_frontend/core/cache/app_cache_service.dart';
import 'package:readiculous_frontend/core/network/api_error.dart';
import 'package:readiculous_frontend/shared/library/data/datasources/library_remote_data_source.dart';
import 'package:readiculous_frontend/shared/library/data/dtos/library_association_requests_dto.dart';
import 'package:readiculous_frontend/shared/library/data/dtos/library_dto.dart';
import 'package:readiculous_frontend/shared/library/data/dtos/user_library_response_dto.dart';
import 'package:readiculous_frontend/shared/library/data/repositories/library_repository_impl.dart';
import 'package:readiculous_frontend/shared/library/domain/entities/library.dart';
import 'package:readiculous_frontend/shared/library/domain/repositories/library_repository.dart';
import 'package:readiculous_frontend/shared/library/domain/usecases/choose_library.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

class _FakeRemote implements LibraryRemoteDataSource {
  LibraryDto? library;
  List<LibraryDto> catalog = [];
  Object? error;
  int calls = 0;
  final writes = <String>[];

  @override
  Future<LibraryDto?> fetchUserLibrary(String userId) async {
    calls++;
    if (error != null) throw error!;
    return library;
  }

  @override
  Future<List<LibraryDto>> fetchAllLibraries() async {
    if (error != null) throw error!;
    return catalog;
  }

  @override
  Future<void> setUserLibrary(String userId, int libraryId) async {
    if (error != null) throw error!;
    writes.add('reader $userId $libraryId');
  }

  @override
  Future<void> assignLibrarian(String userId, int libraryId) async {
    if (error != null) throw error!;
    writes.add('librarian $userId $libraryId');
  }
}

/// Records which association [ChooseLibrary] asked for.
class _RecordingRepository implements LibraryRepository {
  final calls = <String>[];

  @override
  Future<void> setReaderLibrary(String userId, int libraryId) async =>
      calls.add('reader $userId $libraryId');

  @override
  Future<void> assignLibrarian(String userId, int libraryId) async =>
      calls.add('librarian $userId $libraryId');

  @override
  Future<List<Library>> getAllLibraries() async => [];

  @override
  Future<Library?> getUserLibrary(String userId) async => null;
}

class _FakeCache implements AppCacheService {
  Map<String, dynamic>? stored;

  @override
  Future<Map<String, dynamic>?> getCurrentUserLibrary() async => stored;

  @override
  Future<void> saveCurrentUserLibrary(Map<String, dynamic> library) async {
    stored = library;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _chinatown = LibraryDto(
  libraryId: 4,
  name: 'Chicago Public Library - Chinatown',
  location: 'Chicago, IL',
  verified: 1,
);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('UserLibraryResponseDto', () {
    test('parses GET /users/:id/library', () {
      final dto = UserLibraryResponseDto.fromJson({
        'library': {
          'library_id': 4,
          'name': 'Chicago Public Library - Chinatown',
          'location': 'Chicago, IL',
          'verified': 1,
          'association_type': 'librarian',
        },
      });

      final library = dto.library!.toEntity();
      expect(library.libraryId, 4);
      expect(library.name, 'Chicago Public Library - Chinatown');
      expect(library.verified, 1);
    });

    test('a reader with no library is {"library": null}, not a crash', () {
      expect(
          UserLibraryResponseDto.fromJson({'library': null}).library, isNull);
    });
  });

  group('LibraryRepositoryImpl.getUserLibrary', () {
    late _FakeRemote remote;
    late _FakeCache cache;
    late LibraryRepositoryImpl repo;

    final offline = DioException(
      requestOptions: RequestOptions(path: '/users/u1/library'),
      type: DioExceptionType.connectionError,
    );

    setUp(() {
      remote = _FakeRemote();
      cache = _FakeCache();
      repo = LibraryRepositoryImpl(remote, cache);
    });

    test('fetches, then caches the library tagged with the user id', () async {
      remote.library = _chinatown;

      final library = await repo.getUserLibrary('u1');

      expect(library?.name, 'Chicago Public Library - Chinatown');
      expect(cache.stored, {..._chinatown.toJson(), 'user_id': 'u1'});
    });

    test('the server wins over a stale cached library', () async {
      cache.stored = {
        'user_id': 'u1',
        'library_id': 99,
        'name': 'Old Library',
      };
      remote.library = _chinatown;

      final library = await repo.getUserLibrary('u1');

      expect(library?.name, 'Chicago Public Library - Chinatown');
      expect(remote.calls, 1);
    });

    test('offline ⇒ falls back to this user\'s cached library', () async {
      cache.stored = {..._chinatown.toJson(), 'user_id': 'u1'};
      remote.error = offline;

      final library = await repo.getUserLibrary('u1');

      expect(library?.libraryId, 4);
    });

    test("offline never falls back to another user's library", () async {
      cache.stored = {..._chinatown.toJson(), 'user_id': 'someone-else'};
      remote.error = offline;

      await expectLater(
        repo.getUserLibrary('u1'),
        throwsA(isA<ApiError>()
            .having((e) => e.message, 'message', 'No internet connection')),
      );
    });

    test('offline with an unreadable cache ⇒ ApiError', () async {
      cache.stored = {'user_id': 'u1', 'library_id': 'not-a-number'};
      remote.error = offline;

      await expectLater(repo.getUserLibrary('u1'), throwsA(isA<ApiError>()));
    });

    test('no library ⇒ null, and nothing is cached', () async {
      remote.library = null;

      expect(await repo.getUserLibrary('u1'), isNull);
      expect(cache.stored, isNull);
    });
  });

  test('association request bodies use the backend field names', () {
    expect(const SetUserLibraryRequestDto(libraryId: 4).toJson(),
        {'library_id': 4});
    expect(const AssignLibrarianRequestDto(userId: 'u1', libraryId: 4).toJson(),
        {'user_id': 'u1', 'library_id': 4, 'verified': 1});
  });

  group('LibraryRepositoryImpl catalog and association', () {
    late _FakeRemote remote;
    late LibraryRepositoryImpl repo;

    setUp(() {
      remote = _FakeRemote();
      repo = LibraryRepositoryImpl(remote, _FakeCache());
    });

    test('getAllLibraries parses GET /libraries and sorts by name', () async {
      remote.catalog = [
        LibraryDto.fromJson({
          'library_id': 7,
          'name': 'woodlawn',
          'location': 'Chicago, IL',
          'verified': 0,
        }),
        LibraryDto.fromJson({'library_id': 4, 'name': 'Chinatown'}),
        LibraryDto.fromJson({'library_id': 9, 'name': 'Austin'}),
      ];

      final libraries = await repo.getAllLibraries();

      expect(libraries.map((l) => l.name), ['Austin', 'Chinatown', 'woodlawn']);
      expect(libraries.last.location, 'Chicago, IL');
    });

    test('reader and librarian choices reach their own endpoints', () async {
      await repo.setReaderLibrary('u1', 4);
      await repo.assignLibrarian('lib1', 7);

      expect(remote.writes, ['reader u1 4', 'librarian lib1 7']);
    });

    test('a rejected choice keeps the backend message', () async {
      final options = RequestOptions(path: '/users/u1/library');
      remote.error = DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 404,
          data: {'message': 'Library not found'},
        ),
      );

      await expectLater(
        repo.setReaderLibrary('u1', 999),
        throwsA(isA<ApiError>()
            .having((e) => e.message, 'message', 'Library not found')
            .having((e) => e.statusCode, 'statusCode', 404)),
      );
    });

    test('offline catalog ⇒ ApiError', () async {
      remote.error = DioException(
        requestOptions: RequestOptions(path: '/libraries/'),
        type: DioExceptionType.connectionError,
      );

      await expectLater(
        repo.getAllLibraries(),
        throwsA(isA<ApiError>()
            .having((e) => e.message, 'message', 'No internet connection')),
      );
    });
  });

  group('ChooseLibrary', () {
    test('a reader sets their home library', () async {
      final repo = _RecordingRepository();
      await ChooseLibrary(repo).call('u1', 4, asLibrarian: false);
      expect(repo.calls, ['reader u1 4']);
    });

    test('a librarian is assigned to the library', () async {
      final repo = _RecordingRepository();
      await ChooseLibrary(repo).call('lib1', 4, asLibrarian: true);
      expect(repo.calls, ['librarian lib1 4']);
    });
  });
}
