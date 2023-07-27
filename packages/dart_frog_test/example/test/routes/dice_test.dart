import 'dart:io';
import 'dart:math';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_test/dart_frog_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/dice.dart' as route;

class _MockRandom extends Mock implements Random {}

void main() {
  testDartFrog(
    'responds with a 200 and the rolled number.',
    url: '/dice',
    method: HttpMethod.post,
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

  final notAllowedMethods =
      HttpMethod.values.where((v) => v != HttpMethod.post);

  for (final method in notAllowedMethods) {
    testDartFrog(
      'responds with method not allowed.',
      url: '/dice',
      method: method,
      onRequest: route.onRequest,
      expect: (response) {
        expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
      },
    );
  }
}
