import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:test/test.dart';

void main() {
  test('multiple middleware can be used on a handler', () async {
    const stringValue = '__test_value__';
    const intValue = 42;
    Handler provideString(Handler handler) {
      return handler.provide<String>(() => stringValue);
    }

    Handler provideInt(Handler handler) {
      return handler.provide<int>(() => intValue);
    }

    Handler middleware(Handler handler) {
      return handler.use(provideString).use(provideInt);
    }

    Response onRequest(Request request) {
      final resolvedString = request.resolve<String>();
      final resolvedInt = request.resolve<int>();
      return Response.ok('$resolvedString $resolvedInt');
    }

    final handler =
        const Pipeline().addMiddleware(middleware).addHandler(onRequest);

    final request = Request('GET', Uri.parse('http://localhost:8080/'));
    final response = await handler(request);

    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(
      await response.readAsString(),
      equals('$stringValue $intValue'),
    );
  });
}
