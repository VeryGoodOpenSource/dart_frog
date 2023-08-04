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
    route.onRequest,
    TestRequest(path: '/dice', method: HttpMethod.post),
    (tester) async {
      final random = _MockRandom();
      when(() => random.nextInt(6)).thenReturn(2);

      tester.mockDependency<Random>(random);

      final response = await tester.response();
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
    testRouteHandler(
      'responds with method not allowed.',
      route.onRequest,
      TestRequest(path: '/dice', method: method),
      (tester) async {
        final response = await tester.response();
        expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
      },
    );
  }
}
