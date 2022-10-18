import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('E2E', () {
    const greeting = 'Hello';
    test('GET / responds with "Hello"', () async {
      final response = await http.get(Uri.parse('http://localhost:8080'));
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals(greeting));
    });

    test('GET /favicon.ico responds with the favicon.ico', () async {
      final response = await http.get(
        Uri.parse('http://localhost:8080/favicon.ico'),
      );
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, isNotEmpty);
    });

    test('GET /greet/<name> responds with the "Hello <name>"', () async {
      const name = 'Frog';
      final response = await http.get(
        Uri.parse('http://localhost:8080/greet/$name'),
      );
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals('Hello $name'));
    });

    test('GET /users/<id> responds with the "Hello user <id>"', () async {
      const id = 'id';
      final response = await http.get(
        Uri.parse('http://localhost:8080/users/$id'),
      );
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals('$greeting user $id'));
    });

    test('GET /users/<id>/<name> responds with the "Hello <name> (user <id>)"',
        () async {
      const id = 'id';
      const name = 'Frog';
      final response = await http.get(
        Uri.parse('http://localhost:8080/users/$id/$name'),
      );
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals('$greeting $name (user $id)'));
    });

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
