import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('E2E (/messages)', () {
    test('GET /messages responds with 405', () async {
      final response = await http.get(
        Uri.parse('http://localhost:8080/messages'),
      );
      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });

    test('POST /messages responds with 400 when body is empty', () async {
      final response = await http.post(
        Uri.parse('http://localhost:8080/messages'),
      );
      expect(response.statusCode, equals(HttpStatus.badRequest));
    });

    test(
      'POST /messages responds with 200 when body is not empty',
      () async {
        const message = 'hello world';
        final response = await http.post(
          Uri.parse('http://localhost:8080/messages'),
          body: message,
        );
        expect(response.statusCode, equals(HttpStatus.ok));
        expect(response.body, equals('message: $message'));
      },
      skip: true,
    );
  });
}
