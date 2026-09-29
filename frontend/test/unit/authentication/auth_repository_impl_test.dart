import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readiculous_frontend/core/cache/app_cache_service.dart';
import 'package:readiculous_frontend/core/network/api_error.dart';
import 'package:readiculous_frontend/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:readiculous_frontend/features/authentication/data/dtos/login_request_dto.dart';
import 'package:readiculous_frontend/features/authentication/data/dtos/register_request_dto.dart';
import 'package:readiculous_frontend/features/authentication/data/dtos/user_dto.dart';
import 'package:readiculous_frontend/features/authentication/data/repositories/auth_repository_impl.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

const _userDto = UserDto(
  userId: 'u1',
  firstName: 'Ada',
  lastName: 'Lovelace',
  email: 'ada@example.com',
  role: 'user',
);

class _FakeRemote implements AuthRemoteDataSource {
  Object? error;
  LoginRequestDto? lastLogin;
  RegisterRequestDto? lastRegister;

  @override
  Future<UserDto> login(LoginRequestDto request) async {
    lastLogin = request;
    if (error != null) throw error!;
    return _userDto;
  }

  @override
  Future<UserDto> register(RegisterRequestDto request) async {
    lastRegister = request;
    if (error != null) throw error!;
    return _userDto;
  }
}

class _FakeCache implements AppCacheService {
  Map<String, dynamic>? savedProfile;

  @override
  Future<void> saveCurrentUserProfile(Map<String, dynamic> profile) async {
    savedProfile = profile;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DioException _dioError(int status, Map<String, dynamic> body) {
  final options = RequestOptions(path: '/users/login');
  return DioException(
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: status, data: body),
    type: DioExceptionType.badResponse,
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _FakeRemote remote;
  late _FakeCache cache;
  late AuthRepositoryImpl repo;

  setUp(() {
    remote = _FakeRemote();
    cache = _FakeCache();
    repo = AuthRepositoryImpl(remote, cache);
  });

  group('login', () {
    test('returns the user and caches the profile', () async {
      final user = await repo.login(email: 'ada@example.com', password: 'pw');

      expect(user.userId, 'u1');
      expect(remote.lastLogin?.email, 'ada@example.com');
      expect(remote.lastLogin?.password, 'pw');
      expect(cache.savedProfile, _userDto.toJson());
    });

    test('turns a server error into an ApiError with its message', () async {
      remote.error = _dioError(401, {'message': 'Invalid credentials'});

      await expectLater(
        repo.login(email: 'ada@example.com', password: 'wrong'),
        throwsA(isA<ApiError>()
            .having((e) => e.message, 'message', 'Invalid credentials')
            .having((e) => e.statusCode, 'statusCode', 401)),
      );
      expect(cache.savedProfile, isNull);
    });

    test('turns any other failure into "Unexpected error"', () async {
      remote.error = const FormatException('bad json');

      await expectLater(
        repo.login(email: 'ada@example.com', password: 'pw'),
        throwsA(isA<ApiError>()
            .having((e) => e.message, 'message', 'Unexpected error')),
      );
    });
  });

  group('register', () {
    test('sends every form field and returns the created user', () async {
      final user = await repo.register(
        firstName: 'Ada',
        lastName: 'Lovelace',
        email: 'ada@example.com',
        phone: '5551234567',
        dateOfBirth: '1990-01-01',
        password: 'Secret@123',
        location: 'London',
        role: 'user',
      );

      expect(user.email, 'ada@example.com');
      expect(remote.lastRegister?.toJson(), {
        'first_name': 'Ada',
        'last_name': 'Lovelace',
        'email': 'ada@example.com',
        'phone': '5551234567',
        'date_of_birth': '1990-01-01',
        'password': 'Secret@123',
        'location': 'London',
        'role': 'user',
      });
    });

    test('surfaces "Email already exists" from a 409', () async {
      remote.error = _dioError(409, {'message': 'Email already exists'});

      await expectLater(
        repo.register(
          firstName: 'Ada',
          lastName: 'Lovelace',
          email: 'ada@example.com',
          phone: '5551234567',
          dateOfBirth: '1990-01-01',
          password: 'Secret@123',
          location: 'London',
          role: 'user',
        ),
        throwsA(isA<ApiError>()
            .having((e) => e.message, 'message', 'Email already exists')),
      );
    });
  });
}
