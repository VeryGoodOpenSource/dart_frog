import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:test/test.dart';

void main() {
  group('JsonResponse', () {
    test('statusCode defaults to 200', () {
      expect(JsonResponse().statusCode, equals(HttpStatus.ok));
    });
  });
}
