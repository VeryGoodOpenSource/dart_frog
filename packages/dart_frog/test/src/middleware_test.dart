import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  test('multiple middleware can be used on a handler', () async {
    const stringValue = '__test_value__';
    const intValue = 42;
    Handler stringProvider(Handler handler) {
      return handler.use(provider<String>((_) => stringValue));
    }

    Handler intProvider(Handler handler) {
      return handler.use(provider<int>((_) => intValue));
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

    final server = await serve(handler, 'localhost', 3020);
    final client = http.Client();
    final response = await client.get(Uri.parse('http://localhost:3020/'));

    await expectLater(response.statusCode, equals(HttpStatus.ok));
    await expectLater(response.body, equals('$stringValue $intValue'));

    await server.close();
  });

  test('middleware can be used to read the request body', () async {
    Middleware requestValidator() {
      return (handler) {
        return (context) async {
          final body = await context.request.body();
          if (body.isEmpty) return Response(statusCode: HttpStatus.badRequest);
          return handler(context);
        };
      };
    }

    Future<Response> onRequest(RequestContext context) async {
      final body = await context.request.body();
      return Response(body: 'body: $body');
    }

    final handler = const Pipeline()
        .addMiddleware(requestValidator())
        .addHandler(onRequest);

    var request = Request.get(Uri.parse('http://localhost/'));
    var context = _MockRequestContext();
    when(() => context.request).thenReturn(request);
    var response = await handler(context);

    expect(response.statusCode, equals(HttpStatus.badRequest));

    const body = '__test_body__';
    request = Request.get(Uri.parse('http://localhost/'), body: body);
    context = _MockRequestContext();
    when(() => context.request).thenReturn(request);
    response = await handler(context);

    expect(response.statusCode, equals(HttpStatus.ok));
    expect(await response.body(), equals('body: $body'));
  });

  test('middleware can be used to read the response body', () async {
    const emptyBody = '(empty)';
    Middleware responseValidator() {
      return (handler) {
        return (context) async {
          final response = await handler(context);
          final body = await response.body();
          if (body.isEmpty) return Response(body: emptyBody);
          return response;
        };
      };
    }

    Future<Response> onRequest(RequestContext context) async {
      final body = await context.request.body();
      return Response(body: body);
    }

    final handler = const Pipeline()
        .addMiddleware(responseValidator())
        .addHandler(onRequest);

    var request = Request.get(Uri.parse('http://localhost/'));
    var context = _MockRequestContext();
    when(() => context.request).thenReturn(request);
    var response = await handler(context);

    expect(response.statusCode, equals(HttpStatus.ok));
    expect(response.body(), completion(equals(emptyBody)));

    const body = '__test_body__';
    request = Request.get(Uri.parse('http://localhost/'), body: body);
    context = _MockRequestContext();
    when(() => context.request).thenReturn(request);
    response = await handler(context);

    expect(response.statusCode, equals(HttpStatus.ok));
    expect(response.body(), completion(equals(body)));
  });

  test('chaining middleware retains request context', () async {
    const value = 'test-value';
    Middleware noop() => (handler) => (context) => handler(context);

    Future<Response> onRequest(RequestContext context) async {
      final value = context.read<String>();
      return Response(body: value);
    }

    final handler =
        const Pipeline().addMiddleware(noop()).addHandler(onRequest);
    final request = Request.get(Uri.parse('http://localhost/'));
    final context = _MockRequestContext();

    when(() => context.read<String>()).thenReturn(value);
    when(() => context.request).thenReturn(request);

    final response = await handler(context);

    expect(response.statusCode, equals(HttpStatus.ok));
    expect(response.body(), completion(equals(value)));
  });
}
