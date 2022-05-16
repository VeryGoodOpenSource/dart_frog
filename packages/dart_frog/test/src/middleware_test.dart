import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:test/test.dart';

void main() {
  test('multiple middleware can be used on a handler', () async {
    const stringValue = '__test_value__';
    const intValue = 42;
    Handler stringProvider(Handler handler) {
      return handler.use(provider<String>(() => stringValue));
    }

    Handler intProvider(Handler handler) {
      return handler.use(provider<int>(() => intValue));
    }

    Handler middleware(Handler handler) {
      return handler.use(stringProvider).use(intProvider);
    }

    Response onRequest(Request request) {
      final stringValue = read<String>(request);
      final intValue = read<int>(request);
      return Response.ok('$stringValue $intValue');
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
