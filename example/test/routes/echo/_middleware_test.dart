import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/echo/_middleware.dart';

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('middleware', () {
    test('returns 403 when authorization header is missing.', () async {
      final handler = middleware((request) => Response());
      final request = Request.get(Uri.parse('http://localhost/'));
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(request);
      final response = await handler(context);
      expect(response.statusCode, equals(HttpStatus.forbidden));
    });

    test('forwards request when authorization header is present.', () async {
      final handler = middleware((request) => Response());
      final request = Request.get(
        Uri.parse('http://localhost/'),
        headers: {'Authorization': '__token__'},
      );
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(request);
      final response = await handler(context);
      expect(response.statusCode, equals(HttpStatus.ok));
    });
  });
}
