import 'dart:io';
import 'dart:math';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_test/dart_frog_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/dice.dart' as route;

class _MockRandom extends Mock implements Random {}

void main() {
  testRouteHandler(
    'responds with a 200 and the rolled number.',
    request: Request('POST', Uri.parse('https://example/dice')),
    onRequest: route.onRequest,
    setUp: (context) {
      final random = _MockRandom();
      when(() => random.nextInt(6)).thenReturn(2);
      when(() => context.read<Random>()).thenReturn(random);
    },
    expect: (response) {
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(
        response.json(),
        completion(equals({'value': 3})),
      );
    },
  );

  final notAllowedMethods = HttpMethod.values
      .where((v) => v != HttpMethod.post)
      .map((e) => e.name.toUpperCase());

  for (final method in notAllowedMethods) {
    testRouteHandler(
      'responds with method not allowed.',
      request: Request(method, Uri.parse('https://example/dice')),
      onRequest: route.onRequest,
      expect: (response) {
        expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
      },
    );
  }
}
