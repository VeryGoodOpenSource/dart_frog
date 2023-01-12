import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/messages/_middleware.dart';

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('middleware', () {
    final handler = middleware(
      (context) async {
        final body = await context.request.body();
        return Response(body: 'body: $body');
      },
    );

    test('returns 405 when method is not POST', () async {
      final request = Request.get(Uri.parse('http://localhost/'));
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(request);

      final response = await handler(context);
      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });

    test('returns 400 when POST body is empty', () async {
      final request = Request.post(Uri.parse('http://localhost/'));
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(request);

      final response = await handler(context);
      expect(response.statusCode, equals(HttpStatus.badRequest));
    });

    test('returns 200 when POST body is not empty', () async {
      const body = '__test_body__';
      final request = Request.post(Uri.parse('http://localhost/'), body: body);
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(request);

      final response = await handler(context);
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body(), completion(equals('body: $body')));
    });
  });
}
