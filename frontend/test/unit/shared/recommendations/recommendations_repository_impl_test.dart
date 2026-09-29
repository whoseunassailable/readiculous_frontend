import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readiculous_frontend/core/network/api_error.dart';
import 'package:readiculous_frontend/core/session/session_notifier.dart';
import 'package:readiculous_frontend/core/session/session_provider.dart';
import 'package:readiculous_frontend/core/session/session_state.dart';
import 'package:readiculous_frontend/shared/library/domain/entities/library.dart';
import 'package:readiculous_frontend/shared/library/presentation/state_management/library_providers.dart';
import 'package:readiculous_frontend/shared/recommendations/data/datasources/recommendations_remote_data_source.dart';
import 'package:readiculous_frontend/shared/recommendations/data/dtos/library_recommendation_dto.dart';
import 'package:readiculous_frontend/shared/recommendations/data/dtos/recommendation_requests_dto.dart';
import 'package:readiculous_frontend/shared/recommendations/data/dtos/user_recommendation_dto.dart';
import 'package:readiculous_frontend/shared/recommendations/data/repositories/recommendations_repository_impl.dart';
import 'package:readiculous_frontend/shared/recommendations/domain/entities/library_recommendation.dart';
import 'package:readiculous_frontend/shared/recommendations/domain/entities/user_recommendation.dart';
import 'package:readiculous_frontend/shared/recommendations/domain/repositories/recommendations_repository.dart';
import 'package:readiculous_frontend/shared/recommendations/presentation/state_management/recommendations_providers.dart';
import 'package:readiculous_frontend/shared/recommendations/presentation/state_management/user_recommendations_notifier.dart';

// ── Real payloads ─────────────────────────────────────────────────────────────

/// A row from GET /api/recommendations/libraries/4.
Map<String, dynamic> _libraryRow(
        {String? state = 'NEW', Object? score = '0.9642'}) =>
    {
      'recommendation_id': 5,
      'library_id': 4,
      'book_id': 17,
      'title': 'The Midnight Library',
      'author': 'Matt Haig',
      'cover_url': null,
      'demand_score': score,
      'demand_level': 'HIGH',
      'reason': 'Fantasy and drama demand is spiking',
      'state': state,
      'created_at': '2026-04-07T21:02:02.000Z',
      'updated_at': '2026-04-07T21:02:02.000Z',
    };

/// A row from GET /api/recommendations/users/:id.
Map<String, dynamic> _userRow({String? genre = 'Comedy, Mystery, Sci-Fi'}) => {
      'recommendation_id': 112,
      'user_id': 'u1',
      'book_id': 69923,
      'title': 'The Plex Solution',
      'author': 'P.A. Bird',
      'cover_url': 'https://example.com/cover.jpg',
      'genre': genre,
      'score': '0.8288',
      'reason': 'Genres: Action, Adventure, Coming-of-Age',
      'created_at': '2026-04-22T14:37:34.000Z',
      'updated_at': '2026-04-22T14:37:34.000Z',
    };

// ── Fakes ─────────────────────────────────────────────────────────────────────

class _FakeRemote implements RecommendationsRemoteDataSource {
  Object? error;
  final calls = <String>[];

  @override
  Future<List<UserRecommendationDto>> fetchUserRecommendations(
      String userId) async {
    if (error != null) throw error!;
    return [UserRecommendationDto.fromJson(_userRow())];
  }

  @override
  Future<void> generateUserRecommendations(String userId, int topN) async {
    if (error != null) throw error!;
    calls.add('generate user $userId top $topN');
  }

  @override
  Future<List<LibraryRecommendationDto>> fetchLibraryRecommendations(
      int libraryId) async {
    if (error != null) throw error!;
    return [LibraryRecommendationDto.fromJson(_libraryRow())];
  }

  @override
  Future<void> generateLibraryRecommendations(
      int libraryId, int topNBooks) async {
    if (error != null) throw error!;
    calls.add('generate library $libraryId top $topNBooks');
  }

  @override
  Future<void> updateLibraryRecommendationState(
      int recommendationId, String state,
      {int? copies}) async {
    if (error != null) throw error!;
    calls.add('state $recommendationId $state'
        '${copies == null ? '' : ' +$copies'}');
  }
}

/// Saved picks that change when [generateUserRecommendations] runs.
class _FakeRepository implements RecommendationsRepository {
  var generation = 0;
  final calls = <String>[];

  @override
  Future<List<UserRecommendation>> getUserRecommendations(String userId) async {
    calls.add('get $userId');
    return [
      UserRecommendation(
          recommendationId: generation,
          bookId: 1,
          title: 'Pick v$generation',
          score: 0.5),
    ];
  }

  @override
  Future<void> generateUserRecommendations(String userId,
      {int topN = 10}) async {
    calls.add('generate $userId');
    generation++;
  }

  @override
  Future<List<LibraryRecommendation>> getLibraryRecommendations(
          int libraryId) async =>
      [LibraryRecommendationDto.fromJson(_libraryRow()).toEntity()];

  @override
  Future<void> generateLibraryRecommendations(int libraryId,
      {int topNBooks = 10}) async {}

  @override
  Future<void> updateLibraryRecommendationState(
      int recommendationId, String state,
      {int? copies}) async {}
}

class _FixedSession extends SessionNotifier {
  final SessionState _state;
  _FixedSession(this._state);

  @override
  SessionState build() => _state;
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('LibraryRecommendationDto', () {
    test('parses a backend row', () {
      final rec = LibraryRecommendationDto.fromJson(_libraryRow()).toEntity();
      expect(rec.recommendationId, 5);
      expect(rec.title, 'The Midnight Library');
      expect(rec.demandLevel, 'HIGH');
    });

    test('demand_score arrives as a string (MySQL DECIMAL) or a number', () {
      expect(
          LibraryRecommendationDto.fromJson(_libraryRow()).demandScore, 0.9642);
      expect(
          LibraryRecommendationDto.fromJson(_libraryRow(score: 0.5))
              .demandScore,
          0.5);
    });

    test('parses the copies and readers behind a pick', () {
      final rec = LibraryRecommendationDto.fromJson({
        ..._libraryRow(),
        'copies_total': 25,
        'copies_available': 3,
        'readers_waiting': 10,
        'back_soon': 4,
        'readers_per_month': 12.3,
      }).toEntity();

      expect(rec.copiesTotal, 25);
      expect(rec.copiesAvailable, 3);
      expect(rec.copiesOut, 22);
      expect(rec.readersWaiting, 10);
      expect(rec.backSoon, 4);
      expect(rec.readersPerMonth, 12.3);
    });

    test('a row without those facts reads as none', () {
      final rec = LibraryRecommendationDto.fromJson(_libraryRow()).toEntity();
      expect(rec.copiesTotal, 0);
      expect(rec.readersWaiting, 0);
      expect(rec.readersPerMonth, 0);
    });

    test('isPending: NEW or no state; not ORDERED/STOCKED/IGNORED', () {
      LibraryRecommendation rec(String? s) =>
          LibraryRecommendationDto.fromJson(_libraryRow(state: s)).toEntity();
      expect(rec('NEW').isPending, true);
      expect(rec(null).isPending, true);
      expect(rec('ORDERED').isPending, false);
      expect(rec('STOCKED').isPending, false);
      expect(rec('IGNORED').isPending, false);
    });
  });

  group('UserRecommendationDto', () {
    test('parses a backend row, splitting the genres', () {
      final rec = UserRecommendationDto.fromJson(_userRow()).toEntity();
      expect(rec.recommendationId, 112);
      expect(rec.bookId, 69923);
      expect(rec.title, 'The Plex Solution');
      expect(rec.genres, ['Comedy', 'Mystery', 'Sci-Fi']);
      expect(rec.score, 0.8288);
    });

    test('a book without genres falls back to the "Genres:" in the reason', () {
      final rec =
          UserRecommendationDto.fromJson(_userRow(genre: null)).toEntity();
      expect(rec.genres, ['Action', 'Adventure', 'Coming-of-Age']);
    });

    test('no genres anywhere ⇒ empty list', () {
      final rec = UserRecommendationDto.fromJson(
          {..._userRow(genre: ''), 'reason': 'Popular nearby'}).toEntity();
      expect(rec.genres, isEmpty);
    });
  });

  test('request bodies use the backend field names', () {
    expect(const GenerateUserRecommendationsRequestDto(topN: 10).toJson(),
        {'top_n': 10});
    expect(
        const GenerateLibraryRecommendationsRequestDto(topNBooks: 10).toJson(),
        {'top_n_books': 10});
    expect(const UpdateRecommendationStateRequestDto(state: 'STOCKED').toJson(),
        {'state': 'STOCKED'});
    expect(
        const UpdateRecommendationStateRequestDto(state: 'ORDERED', copies: 6)
            .toJson(),
        {'state': 'ORDERED', 'copies': 6});
  });

  group('RecommendationsRepositoryImpl', () {
    test('maps both kinds of recommendation to entities', () async {
      final repo = RecommendationsRepositoryImpl(_FakeRemote());

      expect((await repo.getUserRecommendations('u1')).single.title,
          'The Plex Solution');
      expect((await repo.getLibraryRecommendations(4)).single.title,
          'The Midnight Library');
    });

    test('generate and state changes reach the data source', () async {
      final remote = _FakeRemote();
      final repo = RecommendationsRepositoryImpl(remote);

      await repo.generateUserRecommendations('u1');
      await repo.generateLibraryRecommendations(4);
      await repo.updateLibraryRecommendationState(5, 'STOCKED');
      await repo.updateLibraryRecommendationState(5, 'ORDERED', copies: 6);

      expect(remote.calls, [
        'generate user u1 top 10',
        'generate library 4 top 10',
        'state 5 STOCKED',
        'state 5 ORDERED +6',
      ]);
    });

    test('server errors keep the backend message', () async {
      final options =
          RequestOptions(path: '/recommendations/libraries/4/generate');
      final remote = _FakeRemote()
        ..error = DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {
              'message': "No genre preferences found for this library's members"
            },
          ),
        );

      await expectLater(
        RecommendationsRepositoryImpl(remote).generateLibraryRecommendations(4),
        throwsA(isA<ApiError>().having((e) => e.message, 'message',
            "No genre preferences found for this library's members")),
      );
    });
  });

  group('userRecommendationsProvider', () {
    ProviderContainer container(String? userId, _FakeRepository repo) {
      final c = ProviderContainer(overrides: [
        sessionProvider.overrideWith(() => _FixedSession(
            SessionState(initialized: true, userId: userId, role: 'user'))),
        recommendationsRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(c.dispose);
      c.listen(userRecommendationsProvider, (_, __) {});
      return c;
    }

    test('logged out ⇒ empty, without a request', () async {
      final repo = _FakeRepository();
      final c = container(null, repo);

      expect(await c.read(userRecommendationsProvider.future), isEmpty);
      expect(repo.calls, isEmpty);
    });

    test('generate runs the model, then loads the new picks', () async {
      final repo = _FakeRepository();
      final c = container('u1', repo);
      expect((await c.read(userRecommendationsProvider.future)).single.title,
          'Pick v0');

      await c.read(userRecommendationsProvider.notifier).generate();

      expect(
          c.read(userRecommendationsProvider).value!.single.title, 'Pick v1');
      expect(repo.calls, ['get u1', 'generate u1', 'get u1']);
    });

    test('refresh re-reads the saved picks', () async {
      final repo = _FakeRepository();
      final c = container('u1', repo);
      await c.read(userRecommendationsProvider.future);

      await c.read(userRecommendationsProvider.notifier).refresh();

      expect(repo.calls, ['get u1', 'get u1']);
    });
  });

  group('currentLibraryRecommendationsProvider', () {
    ProviderContainer container({Library? library}) {
      final c = ProviderContainer(overrides: [
        sessionProvider.overrideWith(() => _FixedSession(const SessionState(
            initialized: true, userId: 'lib1', role: 'librarian'))),
        userLibraryProvider('lib1').overrideWith((ref) async => library),
        recommendationsRepositoryProvider.overrideWithValue(_FakeRepository()),
      ]);
      addTearDown(c.dispose);
      return c;
    }

    test('no library ⇒ empty', () async {
      expect(
          await container().read(currentLibraryRecommendationsProvider.future),
          isEmpty);
    });

    test("loads the librarian's library picks", () async {
      final recs = await container(
              library: const Library(libraryId: 4, name: 'Chinatown'))
          .read(currentLibraryRecommendationsProvider.future);
      expect(recs.single.title, 'The Midnight Library');
    });
  });
}
