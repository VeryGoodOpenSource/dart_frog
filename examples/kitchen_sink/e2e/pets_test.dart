import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('E2E (/pets)', () {
    const greeting = 'Hello';
    test('GET /api/pets responds with unauthorized when header is missing',
        () async {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/pets'),
      );
      expect(response.statusCode, equals(HttpStatus.unauthorized));
    });

    test('GET /api/pets responds with "Hello pets"', () async {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/pets'),
        headers: {HttpHeaders.authorizationHeader: 'token'},
      );
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals('$greeting pets'));
    });

    test('GET /api/pets/<name> responds with "Hello <name>"', () async {
      const name = 'Frog';
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/pets/$name'),
        headers: {HttpHeaders.authorizationHeader: 'token'},
      );
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals('$greeting $name'));
    });
  });
}
