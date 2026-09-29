import 'package:flutter_test/flutter_test.dart';
import 'package:readiculous_frontend/features/authentication/data/dtos/login_request_dto.dart';
import 'package:readiculous_frontend/features/authentication/data/dtos/login_response_dto.dart';
import 'package:readiculous_frontend/features/authentication/data/dtos/register_request_dto.dart';
import 'package:readiculous_frontend/features/authentication/data/dtos/register_response_dto.dart';
import 'package:readiculous_frontend/features/authentication/data/dtos/user_dto.dart';

/// Shapes below are copied from backend/src/controllers/userController.js
/// (loginUser and createUser responses).
void main() {
  const userJson = {
    'user_id': 'u1',
    'first_name': 'Ada',
    'last_name': 'Lovelace',
    'email': 'ada@example.com',
    'role': 'user',
  };

  group('UserDto', () {
    test('fromJson → toEntity maps every field', () {
      final user = UserDto.fromJson(userJson).toEntity();

      expect(user.userId, 'u1');
      expect(user.firstName, 'Ada');
      expect(user.lastName, 'Lovelace');
      expect(user.email, 'ada@example.com');
      expect(user.role, 'user');
    });

    test('toJson writes the backend keys (used for the profile cache)', () {
      expect(UserDto.fromJson(userJson).toJson(), userJson);
    });

    test('fromJson throws when a required field is missing', () {
      final json = Map<String, dynamic>.from(userJson)..remove('user_id');
      expect(() => UserDto.fromJson(json), throwsA(isA<TypeError>()));
    });
  });

  test('LoginResponseDto reads the user from "user"', () {
    final dto = LoginResponseDto.fromJson({
      'message': 'Login successful',
      'user': userJson,
    });
    expect(dto.user.userId, 'u1');
  });

  test('RegisterResponseDto reads the user from "data"', () {
    final dto = RegisterResponseDto.fromJson({
      'message': 'User created',
      'data': {
        ...userJson,
        'date_of_birth': '1990-01-01',
        'location': 'London',
        'phone': '5551234567',
      },
    });
    expect(dto.user.email, 'ada@example.com');
  });

  test('LoginRequestDto.toJson', () {
    expect(
      const LoginRequestDto(email: 'a@b.com', password: 'pw').toJson(),
      {'email': 'a@b.com', 'password': 'pw'},
    );
  });

  test('RegisterRequestDto.toJson uses the backend field names', () {
    const dto = RegisterRequestDto(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
      phone: '5551234567',
      dateOfBirth: '1990-01-01',
      password: 'Secret@123',
      location: 'London',
      role: 'user',
    );

    expect(dto.toJson(), {
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
}
