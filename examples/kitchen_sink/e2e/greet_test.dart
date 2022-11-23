import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('E2E (/greet)', () {
    test('GET /greet/<name> responds with the "Hello <name>"', () async {
      const name = 'Frog';
      final response = await http.get(
        Uri.parse('http://localhost:8080/greet/$name'),
      );
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals('Hello $name'));
    });
  });
}
