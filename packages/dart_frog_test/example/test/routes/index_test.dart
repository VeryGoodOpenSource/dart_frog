import 'dart:io';

import 'package:dart_frog_test/dart_frog_test.dart';
import 'package:test/test.dart';

import '../../routes/index.dart' as route;

void main() {
  test(
    'responds with a 200 and "Welcome to Dart Frog!".',
    () async {
      final testContext = DartFrogTestContext(path: '/');
      final response = route.onRequest(testContext.context);
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(
        response.body(),
        completion(equals('Welcome to Dart Frog!')),
      );
    },
  );
}
