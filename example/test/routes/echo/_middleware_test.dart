import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:test/test.dart';

import '../../../routes/echo/_middleware.dart';

void main() {
  group('middleware', () {
    test('returns 403 when authorization header is missing.', () async {
      final handler = middleware((request) => Response.ok(''));
      final request = Request('GET', Uri.parse('http://127.0.0.1/'));
      final response = await handler(request);
      expect(response.statusCode, equals(HttpStatus.forbidden));
    });

    test('forwards request when authorization header is present.', () async {
      final handler = middleware((request) => Response.ok(''));
      final request = Request(
        'GET',
        Uri.parse('http://127.0.0.1/'),
        headers: {'Authorization': '__token__'},
      );
      final response = await handler(request);
      expect(response.statusCode, equals(HttpStatus.ok));
    });
  });
}
