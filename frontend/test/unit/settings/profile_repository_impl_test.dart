import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readiculous_frontend/core/cache/app_cache_service.dart';
import 'package:readiculous_frontend/core/network/api_error.dart';
import 'package:readiculous_frontend/features/settings/data/datasources/profile_remote_data_source.dart';
import 'package:readiculous_frontend/features/settings/data/dtos/change_password_request_dto.dart';
import 'package:readiculous_frontend/features/settings/data/dtos/update_profile_request_dto.dart';
import 'package:readiculous_frontend/features/settings/data/dtos/update_profile_response_dto.dart';
import 'package:readiculous_frontend/features/settings/data/dtos/user_profile_dto.dart';
import 'package:readiculous_frontend/features/settings/data/repositories/profile_repository_impl.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

/// A real response from GET /api/users/:id.
const _profileJson = {
  'user_id': 'u1',
  'first_name': 'Ava',
  'last_name': 'Martinez',
  'role': 'user',
  'date_of_birth': '1999-08-15',
  'location': 'Chicago',
  'email': 'ava@example.com',
  'phone': '3125550100',
  'created_at': '2026-04-07T21:02:02.000Z',
};

class _FakeRemote implements ProfileRemoteDataSource {
  UserProfileDto profile = UserProfileDto.fromJson(_profileJson);
  Object? error;
  UpdateProfileRequestDto? lastUpdate;
  ChangePasswordRequestDto? lastPasswordChange;

  @override
  Future<UserProfileDto> fetchProfile(String userId) async {
    if (error != null) throw error!;
    return profile;
  }

  @override
  Future<UserProfileDto> updateProfile(
      String userId, UpdateProfileRequestDto request) async {
    if (error != null) throw error!;
    lastUpdate = request;
    return UserProfileDto.fromJson({..._profileJson, ...request.toJson()});
  }

  @override
  Future<void> changePassword(
      String userId, ChangePasswordRequestDto request) async {
    if (error != null) throw error!;
    lastPasswordChange = request;
  }
}

class _FakeCache implements AppCacheService {
  Map<String, dynamic>? stored;

  @override
  Future<Map<String, dynamic>?> getCurrentUserProfile() async => stored;

  @override
  Future<void> saveCurrentUserProfile(Map<String, dynamic> profile) async {
    stored = profile;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DioException _serverError(int status, String message) {
  final options = RequestOptions(path: '/users/u1');
  return DioException(
    requestOptions: options,
    response: Response(
        requestOptions: options,
        statusCode: status,
        data: {'message': message}),
  );
}

final _offline = DioException(
  requestOptions: RequestOptions(path: '/users/u1'),
  type: DioExceptionType.connectionError,
);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('UserProfileDto', () {
    test('parses GET /users/:id', () {
      final profile = UserProfileDto.fromJson(_profileJson).toEntity();
      expect(profile.firstName, 'Ava');
      expect(profile.dateOfBirth, '1999-08-15');
      expect(profile.phone, '3125550100');
      expect(profile.location, 'Chicago');
    });

    test('reads the smaller profile the login response caches', () {
      final profile = UserProfileDto.fromJson({
        'user_id': 'u1',
        'first_name': 'Ava',
        'last_name': 'Martinez',
        'email': 'ava@example.com',
        'role': 'user',
      }).toEntity();
      expect(profile.location, '');
      expect(profile.phone, isNull);
      expect(profile.dateOfBirth, isNull);
    });

    test('trims an old cached timestamp to its calendar date', () {
      final dto = UserProfileDto.fromJson(
          {..._profileJson, 'date_of_birth': '1999-08-15T05:00:00.000Z'});
      expect(dto.dateOfBirth, '1999-08-15');
    });

    test('UpdateProfileRequestDto uses the backend field names', () {
      expect(
        const UpdateProfileRequestDto(
          firstName: 'Ava',
          lastName: 'M',
          email: 'a@b.com',
          location: 'Chicago',
        ).toJson(),
        {
          'first_name': 'Ava',
          'last_name': 'M',
          'email': 'a@b.com',
          'location': 'Chicago',
          'phone': null,
          'date_of_birth': null,
        },
      );
    });

    test('UpdateProfileResponseDto reads the user from "user"', () {
      final dto = UpdateProfileResponseDto.fromJson(
          {'message': 'Profile updated', 'user': _profileJson});
      expect(dto.user.email, 'ava@example.com');
    });
  });

  group('ProfileRepositoryImpl', () {
    late _FakeRemote remote;
    late _FakeCache cache;
    late ProfileRepositoryImpl repo;

    setUp(() {
      remote = _FakeRemote();
      cache = _FakeCache();
      repo = ProfileRepositoryImpl(remote, cache);
    });

    test('getProfile fetches and caches', () async {
      final profile = await repo.getProfile('u1');
      expect(profile.email, 'ava@example.com');
      expect(cache.stored?['user_id'], 'u1');
    });

    test('getProfile offline ⇒ this user\'s cached copy', () async {
      cache.stored = {..._profileJson, 'first_name': 'Cached'};
      remote.error = _offline;

      expect((await repo.getProfile('u1')).firstName, 'Cached');
    });

    test("getProfile offline never returns another user's profile", () async {
      cache.stored = {..._profileJson, 'user_id': 'someone-else'};
      remote.error = _offline;

      await expectLater(repo.getProfile('u1'), throwsA(isA<ApiError>()));
    });

    test('updateProfile sends the fields and caches the result', () async {
      final profile = await repo.updateProfile(
        userId: 'u1',
        firstName: 'Ava',
        lastName: 'Lopez',
        email: 'ava.lopez@example.com',
        location: 'Evanston',
        phone: null,
        dateOfBirth: '1999-08-16',
      );

      expect(remote.lastUpdate?.lastName, 'Lopez');
      expect(profile.email, 'ava.lopez@example.com');
      expect(cache.stored?['location'], 'Evanston');
    });

    test('updateProfile surfaces "Email already exists" (409)', () async {
      remote.error = _serverError(409, 'Email already exists');

      await expectLater(
        repo.updateProfile(
          userId: 'u1',
          firstName: 'Ava',
          lastName: 'M',
          email: 'taken@example.com',
          location: 'Chicago',
        ),
        throwsA(isA<ApiError>()
            .having((e) => e.message, 'message', 'Email already exists')),
      );
      expect(cache.stored, isNull);
    });

    test('changePassword sends current and new password', () async {
      await repo.changePassword(
          userId: 'u1', currentPassword: 'Old@1234', newPassword: 'New@12345');

      expect(remote.lastPasswordChange?.toJson(), {
        'current_password': 'Old@1234',
        'new_password': 'New@12345',
      });
    });

    test('changePassword surfaces "Current password is incorrect" (401)',
        () async {
      remote.error = _serverError(401, 'Current password is incorrect');

      await expectLater(
        repo.changePassword(
            userId: 'u1', currentPassword: 'wrong', newPassword: 'New@12345'),
        throwsA(isA<ApiError>().having(
            (e) => e.message, 'message', 'Current password is incorrect')),
      );
    });
  });
}
