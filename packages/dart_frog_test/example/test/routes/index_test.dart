import 'dart:io';

import 'package:dart_frog_test/dart_frog_test.dart';
import 'package:test/test.dart';

import '../../routes/index.dart' as route;

void main() {
  testRouteHandler(
    'responds with a 200 and "Welcome to Dart Frog!".',
    route.onRequest,
    TestRequest(path: '/'),
    (tester) async {
      final response = await tester.response();
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(
        response.body(),
        completion(equals('Welcome to Dart Frog!')),
      );
    },
  );
}
