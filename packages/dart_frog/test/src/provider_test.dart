import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  setUp(resetProviders);

  test('values can be provided and read via middleware', () async {
    const value = '__test_value__';

    Middleware valueProvider() => provider<String>((_) => value);

    Handler middleware(Handler handler) => handler.use(valueProvider());

    Response onRequest(RequestContext context) {
      return Response(body: context.read<String>());
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

  test('provided sync values are cached by default', () async {
    const value = '__test_value__';
    var createCallCount = 0;

    Middleware valueProvider() {
      return provider<String>((_) {
        createCallCount++;
        return value;
      });
    }

    Handler middleware(Handler handler) => handler.use(valueProvider());

    Response onRequest(RequestContext context) {
      return Response(body: context.read<String>());
    }

    final handler =
        const Pipeline().addMiddleware(middleware).addHandler(onRequest);

    final request = Request.get(Uri.parse('http://localhost/'));
    final context = _MockRequestContext();
    when(() => context.request).thenReturn(request);

    expect(createCallCount, equals(0));

    var response = await handler(context);

    expect(createCallCount, equals(1));
    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(await response.body(), equals(value));

    response = await handler(context);

    expect(createCallCount, equals(1));
    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(await response.body(), equals(value));
  });

  test('provided async values are cached by default', () async {
    const value = '__test_value__';
    var createCallCount = 0;

    Middleware valueProvider() {
      return provider<Future<String>>((_) async {
        createCallCount++;
        return value;
      });
    }

    Handler middleware(Handler handler) => handler.use(valueProvider());

    Future<Response> onRequest(RequestContext context) async {
      return Response(body: await context.read<Future<String>>());
    }

    final handler =
        const Pipeline().addMiddleware(middleware).addHandler(onRequest);

    final request = Request.get(Uri.parse('http://localhost/'));
    final context = _MockRequestContext();
    when(() => context.request).thenReturn(request);

    expect(createCallCount, equals(0));

    var response = await handler(context);

    expect(createCallCount, equals(1));
    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(await response.body(), equals(value));

    response = await handler(context);

    expect(createCallCount, equals(1));
    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(await response.body(), equals(value));
  });

  test('provided values are lazy by default', () async {
    const value = '__test_value__';
    var createCallCount = 0;

    Middleware valueProvider() {
      return provider<String>((_) {
        createCallCount++;
        return value;
      });
    }

    Handler middleware(Handler handler) => handler.use(valueProvider());

    Response onRequest(RequestContext context) => Response();

    final handler =
        const Pipeline().addMiddleware(middleware).addHandler(onRequest);

    final request = Request.get(Uri.parse('http://localhost/'));
    final context = _MockRequestContext();
    when(() => context.request).thenReturn(request);

    final response = await handler(context);

    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(await response.body(), isEmpty);

    expect(createCallCount, equals(0));
  });

  test('values are eagerly computed when lazy is false', () async {
    const value = '__test_value__';
    var createCallCount = 0;

    Middleware valueProvider() {
      return provider<String>(
        (_) {
          createCallCount++;
          return value;
        },
        lazy: false,
      );
    }

    Handler middleware(Handler handler) => handler.use(valueProvider());

    Response onRequest(RequestContext context) => Response();

    final handler =
        const Pipeline().addMiddleware(middleware).addHandler(onRequest);

    final request = Request.delete(Uri.parse('http://localhost/'));
    final context = _MockRequestContext();
    when(() => context.request).thenReturn(request);

    final response = await handler(context);

    expect(createCallCount, equals(1));

    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(await response.body(), isEmpty);
  });

  test('values are recomputed when cache is false', () async {
    const value = '__test_value__';
    var createCallCount = 0;

    Middleware valueProvider() {
      return provider<String>(
        (_) {
          createCallCount++;
          return value;
        },
        cache: false,
      );
    }

    Handler middleware(Handler handler) => handler.use(valueProvider());

    Response onRequest(RequestContext context) {
      return Response(body: context.read<String>());
    }

    final handler =
        const Pipeline().addMiddleware(middleware).addHandler(onRequest);

    final request = Request.delete(Uri.parse('http://localhost/'));
    final context = _MockRequestContext();
    when(() => context.request).thenReturn(request);

    var response = await handler(context);

    expect(createCallCount, equals(1));

    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(await response.body(), equals(value));

    response = await handler(context);

    expect(createCallCount, equals(2));

    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(await response.body(), equals(value));
  });

  test('cached provided values can be reset', () async {
    const value = '__test_value__';
    var createCallCount = 0;

    Middleware valueProvider() {
      return provider<String>((_) {
        createCallCount++;
        return value;
      });
    }

    Handler middleware(Handler handler) => handler.use(valueProvider());

    Response onRequest(RequestContext context) {
      final value = context.read<String>();
      return Response(body: value);
    }

    final handler =
        const Pipeline().addMiddleware(middleware).addHandler(onRequest);

    final request = Request.get(Uri.parse('http://localhost/'));
    final context = _MockRequestContext();
    when(() => context.request).thenReturn(request);

    expect(createCallCount, equals(0));

    var response = await handler(context);

    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(await response.body(), equals(value));

    expect(createCallCount, equals(1));

    response = await handler(context);

    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(await response.body(), equals(value));

    expect(createCallCount, equals(1));

    resetProvider<String>();

    response = await handler(context);

    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(await response.body(), equals(value));

    expect(createCallCount, equals(2));
  });

  test('descendant providers can access provided values', () async {
    const url = 'http://localhost/';
    Handler middleware(Handler handler) {
      return handler
          .use(provider<Uri>((context) => Uri.parse(context.read<String>())))
          .use(provider<String>((_) => url));
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
