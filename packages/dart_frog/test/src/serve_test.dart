import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:test/test.dart';

void main() {
  group('serve', () {
    test('creates an HttpServer on the provided port/address', () async {
      final server = await serve((_) => Response(), 'localhost', 3000);
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('http://localhost:3000'));
      final response = await request.close();
      expect(response.statusCode, equals(HttpStatus.ok));
      await server.close();
    });
  });
}
