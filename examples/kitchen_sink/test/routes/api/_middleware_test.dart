import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/api/_middleware.dart';

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('middleware', () {
    test('returns unauthorized when Authorization header is missing', () async {
      final handler = middleware(
        (context) => Response(body: ''),
      );
      final request = Request.get(Uri.parse('http://localhost/'));
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(request);

      final response = await handler(context);
      expect(response.statusCode, equals(HttpStatus.unauthorized));
    });

    test('proxies request when Authorization header is present', () async {
      final handler = middleware(
        (context) => Response(body: ''),
      );
      final request = Request.get(
        Uri.parse('http://localhost/'),
        headers: {HttpHeaders.authorizationHeader: 'token'},
      );
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(request);

      final response = await handler(context);
      expect(response.statusCode, equals(HttpStatus.ok));
    });
  });
}
