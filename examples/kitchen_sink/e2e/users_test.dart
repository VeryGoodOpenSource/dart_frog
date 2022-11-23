import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('E2E (/users)', () {
    const greeting = 'Hello';
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
  });
}
