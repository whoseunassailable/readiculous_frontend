import 'package:flutter_test/flutter_test.dart';
import 'package:readiculous_frontend/core/network/dio_client.dart';

void main() {
  group('summarizeBody (dev HTTP log)', () {
    test('a large list logs its length and first item, not every row', () {
      final catalog = [
        for (var i = 0; i < 85000; i++)
          {'book_id': i, 'title': 'Book $i', 'description': 'x' * 500},
      ];

      final logged = summarizeBody(catalog);

      expect(logged, startsWith('List of 85000 item(s). First:'));
      expect(logged, contains('"title": "Book 0"'));
      expect(logged, isNot(contains('Book 1"')));
      expect(logged.length, lessThan(1000));
    });

    test('small bodies are pretty-printed in full', () {
      expect(summarizeBody({'message': 'ok'}), '{\n  "message": "ok"\n}');
      expect(summarizeBody(null), 'null');
      expect(summarizeBody(const []), '[]');
    });

    test('a long body is cut, saying how long it was', () {
      final logged = summarizeBody({'text': 'y' * 10000}, maxChars: 100);

      expect(logged.length, lessThan(200));
      expect(logged, endsWith('characters)'));
    });

    test('a long plain-text body is cut too', () {
      final logged = summarizeBody('z' * 10000, maxChars: 100);

      expect(logged, startsWith('z' * 100));
      expect(logged, endsWith('(10000 characters)'));
    });
  });
}
