import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:test/test.dart';

void main() {
  test('values can be provided/resolved via middleware', () async {
    const value = '__test_value__';
    Handler middleware(Handler handler) {
      return handler.provide<String>(() => value);
    }

    Response onRequest(Request request) {
      final resolved = request.resolve<String>();
      return Response.ok(resolved);
    }

    final handler =
        const Pipeline().addMiddleware(middleware).addHandler(onRequest);

    final request = Request('GET', Uri.parse('http://localhost:8080/'));
    final response = await handler(request);

    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(await response.readAsString(), equals(value));
  });

  test('A StateError is thrown when resolving an un-provided value', () async {
    Response onRequest(Request request) {
      final resolved = request.resolve<String>();
      return Response.ok(resolved);
    }

    final request = Request('GET', Uri.parse('http://localhost:8080/'));

    await expectLater(() => onRequest(request), throwsStateError);
  });
}
