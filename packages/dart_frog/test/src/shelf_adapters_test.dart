import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog/src/_internal.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
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

  group('toShelfHandler', () {
    test('converts a Handler into a shelf.Handler', () async {
      Future<Response> handler(RequestContext context) async {
        return Response(body: 'Hello World');
      }

      final server = await shelf_io.serve(
        toShelfHandler(handler),
        'localhost',
        8001,
      );
      final response = await http.get(Uri.parse('http://localhost:8001'));
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

      final server = await serve(handler, 'localhost', 8002);
      var response = await http.get(Uri.parse('http://localhost:8002'));
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals('Hello World'));
      response = await http.get(
        Uri.parse('http://localhost:8002').replace(
          queryParameters: const <String, String>{'foo': 'bar'},
        ),
      );
      expect(response.statusCode, equals(HttpStatus.badRequest));
      expect(response.body, equals('oops!'));
      await server.close();
    });
  });

  group('toShelfMiddleware', () {
    test('converts a Middleware into a shelf.Middleware', () async {
      Handler middleware(Handler handler) {
        return (context) {
          if (context.request.url.queryParameters.containsKey('foo')) {
            return Response(statusCode: HttpStatus.badRequest, body: 'oops!');
          }
          return handler(context);
        };
      }

      final handler = const shelf.Pipeline()
          .addMiddleware(toShelfMiddleware(middleware))
          .addHandler((_) => shelf.Response.ok('Hello World'));

      final server = await shelf_io.serve(handler, 'localhost', 8003);
      var response = await http.get(Uri.parse('http://localhost:8003'));
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals('Hello World'));
      response = await http.get(
        Uri.parse('http://localhost:8003').replace(
          queryParameters: const <String, String>{'foo': 'bar'},
        ),
      );
      expect(response.statusCode, equals(HttpStatus.badRequest));
      expect(response.body, equals('oops!'));
      await server.close();
    });
  });
}
