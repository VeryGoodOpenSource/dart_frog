import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('E2E', () {
    test('GET /<message> echos back <message>', () async {
      final messages = ['hello', 'world'];
      for (final message in messages) {
        final response = await http.get(
          Uri.parse('http://localhost:8080/$message'),
        );
        expect(response.statusCode, equals(HttpStatus.ok));
        expect(response.body, equals(message));
      }
    });
  });
}
