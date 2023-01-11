import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/messages/index.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('POST /', () {
    test('responds with a 200 and message in body', () async {
      const message = 'Hello World';
      final request = Request.post(
        Uri.parse('http://localhost/'),
        body: message,
      );
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(request);
      final response = await route.onRequest(context);
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body(), completion(equals('message: $message')));
    });
  });
}
