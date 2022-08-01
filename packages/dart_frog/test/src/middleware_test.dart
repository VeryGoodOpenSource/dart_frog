import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  test('multiple middleware can be used on a handler', () async {
    const stringValue = '__test_value__';
    const intValue = 42;
    Handler stringProvider(Handler handler) {
      return handler.use(provider<String>(create: (_) => stringValue));
    }

    Handler intProvider(Handler handler) {
      return handler.use(provider<int>(create: (_) => intValue));
    }

    Handler middleware(Handler handler) {
      return handler.use(stringProvider).use(intProvider);
    }

    Response onRequest(RequestContext context) {
      final stringValue = context.read<String>();
      final intValue = context.read<int>();
      return Response(body: '$stringValue $intValue');
    }

    final handler =
        const Pipeline().addMiddleware(middleware).addHandler(onRequest);

    final request = Request.get(Uri.parse('http://localhost/'));
    final context = _MockRequestContext();
    when(() => context.request).thenReturn(request);
    final response = await handler(context);

    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(
      await response.body(),
      equals('$stringValue $intValue'),
    );
  });
}
