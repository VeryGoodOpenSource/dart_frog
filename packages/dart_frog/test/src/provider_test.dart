import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  test('values can be provided and read via middleware', () async {
    const value = '__test_value__';
    Handler middleware(Handler handler) {
      return handler.use(provider<String>(create: (_) => value));
    }

    Response onRequest(RequestContext context) {
      final value = context.read<String>();
      return Response(body: value);
    }

    final handler =
        const Pipeline().addMiddleware(middleware).addHandler(onRequest);

    final request = Request.get(Uri.parse('http://localhost/'));
    final context = _MockRequestContext();
    when(() => context.request).thenReturn(request);
    final response = await handler(context);

    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(await response.body(), equals(value));
  });

  test(
      'futures can be provided, '
      'read synchronously via middleware, '
      'and are cached by default.', () async {
    const value = '__test_value__';
    var createCallCount = 0;

    Handler middleware(Handler handler) {
      return handler.use(
        futureProvider<String>(
          create: (_) async {
            createCallCount++;
            return value;
          },
        ),
      );
    }

    Response onRequest(RequestContext context) {
      final value = context.read<String>();
      return Response(body: value);
    }

    final handler =
        const Pipeline().addMiddleware(middleware).addHandler(onRequest);

    final request = Request.get(Uri.parse('http://localhost/'));
    final context = _MockRequestContext();
    when(() => context.request).thenReturn(request);

    var response = await handler(context);

    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(await response.body(), equals(value));
    expect(createCallCount, equals(1));

    response = await handler(context);

    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(await response.body(), equals(value));
    expect(createCallCount, equals(1));
  });

  test(
      'futures values can be provided, '
      'read synchronously via middleware, '
      'and recomputed when cache is false', () async {
    const value = '__test_value__';
    var createCallCount = 0;

    Handler middleware(Handler handler) {
      return handler.use(
        futureProvider<String>(
          create: (_) async {
            createCallCount++;
            return value;
          },
          cache: false,
        ),
      );
    }

    Response onRequest(RequestContext context) {
      final value = context.read<String>();
      return Response(body: value);
    }

    final handler =
        const Pipeline().addMiddleware(middleware).addHandler(onRequest);

    final request = Request.get(Uri.parse('http://localhost/'));
    final context = _MockRequestContext();
    when(() => context.request).thenReturn(request);

    var response = await handler(context);

    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(await response.body(), equals(value));
    expect(createCallCount, equals(1));

    response = await handler(context);

    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(await response.body(), equals(value));
    expect(createCallCount, equals(2));
  });

  test('descendant providers can access provided values', () async {
    const url = 'http://localhost/';
    Handler middleware(Handler handler) {
      return handler
          .use(
            provider<Uri>(
              create: (context) => Uri.parse(context.read<String>()),
            ),
          )
          .use(provider<String>(create: (_) => url));
    }

    Response onRequest(RequestContext context) {
      final value = context.read<Uri>();
      return Response(body: value.toString());
    }

    final handler =
        const Pipeline().addMiddleware(middleware).addHandler(onRequest);

    final request = Request.get(Uri.parse('http://localhost/'));
    final context = _MockRequestContext();
    when(() => context.request).thenReturn(request);
    final response = await handler(context);

    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(await response.body(), equals(url));
  });

  test('A StateError is thrown when reading an un-provided value', () async {
    Response onRequest(RequestContext context) {
      context.read<Uri>();
      return Response();
    }

    final handler = const Pipeline()
        .addMiddleware((handler) => handler)
        .addHandler(onRequest);

    final request = Request.get(Uri.parse('http://localhost/'));
    final context = _MockRequestContext();
    when(() => context.request).thenReturn(request);

    await expectLater(() => handler(context), throwsStateError);
  });
}
