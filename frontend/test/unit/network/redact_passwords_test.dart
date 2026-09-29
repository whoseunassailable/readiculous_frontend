import 'package:flutter_test/flutter_test.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';

void main() {
  group('redactPasswords (dev HTTP log)', () {
    test('masks every password-like field', () {
      expect(
        redactPasswords({
          'email': 'ada@example.com',
          'password': 'Secret@123',
          'current_password': 'Old@1234',
          'new_password': 'New@12345',
          'Password': 'Mixed@Case1',
        }),
        {
          'email': 'ada@example.com',
          'password': '***',
          'current_password': '***',
          'new_password': '***',
          'Password': '***',
        },
      );
    });

    test('masks nested maps and lists', () {
      expect(
        redactPasswords({
          'users': [
            {'name': 'a', 'password': 'x'},
          ],
          'meta': {'password': 'y', 'count': 1},
        }),
        {
          'users': [
            {'name': 'a', 'password': '***'},
          ],
          'meta': {'password': '***', 'count': 1},
        },
      );
    });

    test('leaves bodies without passwords and non-map bodies alone', () {
      expect(
          redactPasswords({
            'genre_ids': [1, 2]
          }),
          {
            'genre_ids': [1, 2]
          });
      expect(redactPasswords('raw text'), 'raw text');
      expect(redactPasswords(null), isNull);
    });
  });
}
