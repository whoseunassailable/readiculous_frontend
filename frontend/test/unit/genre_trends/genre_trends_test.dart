import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readiculous_frontend/core/network/api_error.dart';
import 'package:readiculous_frontend/core/session/session_notifier.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/core/session/session_state.dart';
import 'package:readiculous_frontend/features/genre_trends/data/datasources/trends_remote_data_source.dart';
import 'package:readiculous_frontend/features/genre_trends/data/dtos/genre_trend_dto.dart';
import 'package:readiculous_frontend/features/genre_trends/data/repositories/trends_repository_impl.dart';
import 'package:readiculous_frontend/features/genre_trends/domain/entities/genre_trend.dart';
import 'package:readiculous_frontend/features/genre_trends/domain/repositories/trends_repository.dart';
import 'package:readiculous_frontend/features/genre_trends/presentation/state_management/trends_providers.dart';
import 'package:readiculous_frontend/shared/library/domain/entities/library.dart';
import 'package:readiculous_frontend/shared/library/presentation/state_management/library_providers.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

class _FakeRemote implements TrendsRemoteDataSource {
  List<GenreTrendDto> rows = [];
  Object? error;

  @override
  Future<List<GenreTrendDto>> fetchTopTrends(int libraryId) async {
    if (error != null) throw error!;
    return rows;
  }
}

class _FakeRepository implements TrendsRepository {
  int? requestedLibraryId;

  @override
  Future<List<GenreTrend>> getTopTrends(int libraryId) async {
    requestedLibraryId = libraryId;
    return const [GenreTrend(genreId: 23, name: 'Fantasy', score: 9.4)];
  }
}

class _FixedSession extends SessionNotifier {
  final SessionState _state;
  _FixedSession(this._state);

  @override
  SessionState build() => _state;
}

ProviderContainer _container({String? userId, Library? library}) {
  final repo = _FakeRepository();
  final container = ProviderContainer(overrides: [
    sessionProvider.overrideWith(() => _FixedSession(
        SessionState(initialized: true, userId: userId, role: 'librarian'))),
    trendsRepositoryProvider.overrideWithValue(repo),
    if (userId != null)
      userLibraryProvider(userId).overrideWith((ref) async => library),
  ]);
  addTearDown(container.dispose);
  return container;
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('GenreTrendDto', () {
    // A real row from GET /api/trends/top?library_id=4.
    const row = {
      'genre_id': 23,
      'genre_name': 'Fantasy',
      'score': 9.4,
      'captured_at': '2026-04-07T21:02:02.000Z',
    };

    test('parses GET /trends/top', () {
      final trend = GenreTrendDto.fromJson(row).toEntity();
      expect(trend.genreId, 23);
      expect(trend.name, 'Fantasy');
      expect(trend.score, 9.4);
    });

    test('also accepts a DECIMAL string score', () {
      expect(GenreTrendDto.fromJson({...row, 'score': '8.90'}).score, 8.9);
    });
  });

  group('TrendsRepositoryImpl', () {
    test('maps rows to entities in the order the server ranked them', () async {
      final remote = _FakeRemote()
        ..rows = const [
          GenreTrendDto(genreId: 23, genreName: 'Fantasy', score: 9.4),
          GenreTrendDto(genreId: 36, genreName: 'Mystery', score: 8.9),
        ];

      final trends = await TrendsRepositoryImpl(remote).getTopTrends(4);

      expect(trends.map((t) => t.name), ['Fantasy', 'Mystery']);
    });

    test('server error ⇒ ApiError with the backend message', () async {
      final options = RequestOptions(path: '/trends/top');
      final remote = _FakeRemote()
        ..error = DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {'message': 'library_id must be a positive integer'},
          ),
        );

      await expectLater(
        TrendsRepositoryImpl(remote).getTopTrends(4),
        throwsA(isA<ApiError>().having((e) => e.message, 'message',
            'library_id must be a positive integer')),
      );
    });
  });

  group('genreTrendsProvider', () {
    test('logged out ⇒ empty', () async {
      final c = _container();
      expect(await c.read(genreTrendsProvider.future), isEmpty);
    });

    test('no library ⇒ empty, without asking for trends', () async {
      final c = _container(userId: 'lib1', library: null);
      expect(await c.read(genreTrendsProvider.future), isEmpty);
      expect(
          (c.read(trendsRepositoryProvider) as _FakeRepository)
              .requestedLibraryId,
          isNull);
    });

    test("loads the librarian's library trends", () async {
      final c = _container(
        userId: 'lib1',
        library: const Library(libraryId: 4, name: 'Chinatown'),
      );

      final trends = await c.read(genreTrendsProvider.future);

      expect(trends.single.name, 'Fantasy');
      expect(
          (c.read(trendsRepositoryProvider) as _FakeRepository)
              .requestedLibraryId,
          4);
    });
  });
}
