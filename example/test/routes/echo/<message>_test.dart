import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:test/test.dart';

import '../../../routes/echo/<message>.dart' as route;

void main() {
  group('GET /<message>', () {
    test('responds with a 200 and echos the message.', () async {
      const message = 'echo';
      final request = Request('GET', Uri.parse('http://127.0.0.1/$message'));
      final response = route.onRequest(request, message);
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.readAsString(), completion(equals(message)));
    });
  });
}
