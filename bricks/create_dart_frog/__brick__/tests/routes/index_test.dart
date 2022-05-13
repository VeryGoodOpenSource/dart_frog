import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:test/test.dart';

import '../../routes/index.dart' as route;

void main() {
  group('GET /', () {
    test('responds with a 200 and "Welcome to Dart Frog!".', () {
      final request = Request('GET', Uri.parse('http://127.0.0.1/'));
      final response = route.onRequest(request);
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(
        response.readAsString(),
        completion(equals('Welcome to Dart Frog!')),
      );
    });
  });
}
