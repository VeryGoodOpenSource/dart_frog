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

    test('can return multiple 404s', () async {
      final server = await serve(Router(), 'localhost', 3001);
      final client = HttpClient();
      var request = await client.getUrl(Uri.parse('http://localhost:3001'));
      var response = await request.close();
      expect(response.statusCode, equals(HttpStatus.notFound));
      request = await client.getUrl(Uri.parse('http://localhost:3001'));
      response = await request.close();
      expect(response.statusCode, equals(HttpStatus.notFound));
      await server.close();
    });

    test('exposes connectionInfo on incoming request', () async {
      late HttpConnectionInfo connectionInfo;
      final server = await serve(
        (context) {
          connectionInfo = context.request.connectionInfo;
          return Response();
        },
        'localhost',
        3000,
      );
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('http://localhost:3000'));
      await request.close();
      expect(connectionInfo, isA<HttpConnectionInfo>());
      await server.close();
    });
  });
}
