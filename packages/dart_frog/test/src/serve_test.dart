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

    test('exposes connectionInfo on the incoming request', () async {
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
      expect(connectionInfo.remoteAddress.address, equals('::1'));
      await server.close();
    });

    group('X-Powered-By-Header', () {
      test('is configured by default', () async {
        final server = await serve((_) => Response(), 'localhost', 3000);
        final client = HttpClient();
        final request = await client.getUrl(Uri.parse('http://localhost:3000'));
        final response = await request.close();
        expect(
          response.headers.value('X-Powered-By'),
          equals('Dart with package:dart_frog'),
        );
        await server.close();
      });

      test('can be overridden', () async {
        const poweredByHeader = 'custom powered by header';
        final server = await serve(
          (_) => Response(),
          'localhost',
          3000,
          poweredByHeader: poweredByHeader,
        );
        final client = HttpClient();
        final request = await client.getUrl(Uri.parse('http://localhost:3000'));
        final response = await request.close();
        expect(
          response.headers.value('X-Powered-By'),
          equals(poweredByHeader),
        );
        await server.close();
      });

      test('can be removed', () async {
        final server = await serve(
          (_) => Response(),
          'localhost',
          3000,
          poweredByHeader: null,
        );
        final client = HttpClient();
        final request = await client.getUrl(Uri.parse('http://localhost:3000'));
        final response = await request.close();
        expect(response.headers.value('X-Powered-By'), isNull);
        await server.close();
      });
    });
  });
}
