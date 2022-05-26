import 'dart:io';

import 'package:dart_frog/src/_internal.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart' as shelf;
import 'package:test/test.dart';

void main() {
  group('fromShelfHandler', () {
    test('converts a shelf.Handler into a Handler', () async {
      Future<shelf.Response> handler(shelf.Request request) async {
        return shelf.Response.ok('Hello World');
      }

      final server = await serve(fromShelfHandler(handler), 'localhost', 8000);
      final response = await http.get(Uri.parse('http://localhost:8000'));
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals('Hello World'));
      await server.close();
    });
  });

  group('fromShelfMiddleware', () {
    test('converts a shelf.Middleware into a Middleware', () async {
      shelf.Handler middleware(shelf.Handler handler) {
        return (request) {
          if (request.url.queryParameters.containsKey('foo')) {
            return shelf.Response.badRequest(body: 'oops!');
          }
          return handler(request);
        };
      }

      final handler = const Pipeline()
          .addMiddleware(fromShelfMiddleware(middleware))
          .addHandler((_) => Response(body: 'Hello World'));

      final server = await serve(handler, 'localhost', 8001);
      var response = await http.get(Uri.parse('http://localhost:8001'));
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals('Hello World'));
      response = await http.get(
        Uri.parse('http://localhost:8001').replace(
          queryParameters: const <String, String>{'foo': 'bar'},
        ),
      );
      expect(response.statusCode, equals(HttpStatus.badRequest));
      expect(response.body, equals('oops!'));
      await server.close();
    });
  });
}
