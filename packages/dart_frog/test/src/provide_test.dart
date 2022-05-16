import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:test/test.dart';

void main() {
  test('values can be provided and read via middleware', () async {
    const value = '__test_value__';
    Handler middleware(Handler handler) {
      return handler.use(provider<String>(() => value));
    }

    Response onRequest(Request request) {
      final value = read<String>(request);
      return Response.ok(value);
    }

    final handler =
        const Pipeline().addMiddleware(middleware).addHandler(onRequest);

    final request = Request('GET', Uri.parse('http://localhost:8080/'));
    final response = await handler(request);

    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(await response.readAsString(), equals(value));
  });

  test('A StateError is thrown when reading an un-provided value', () async {
    Response onRequest(Request request) {
      final value = read<String>(request);
      return Response.ok(value);
    }

    final request = Request('GET', Uri.parse('http://localhost:8080/'));

    await expectLater(() => onRequest(request), throwsStateError);
  });
}
