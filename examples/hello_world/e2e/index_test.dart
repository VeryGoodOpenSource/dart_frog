import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('E2E', () {
    test('GET / responds with "Welcome to Dart Frog!"', () async {
      final response = await http.get(Uri.parse('http://localhost:8080'));
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals('Welcome to Dart Frog!'));
    });

    test('GET /favicon.ico responds with the favicon.cio', () async {
      final response = await http.get(
        Uri.parse('http://localhost:8080/favicon.ico'),
      );
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, isNotEmpty);
    });
  });
}
