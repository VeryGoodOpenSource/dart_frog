import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('E2E', () {
    test('GET / increments the count on each request', () async {
      const numRequests = 10;
      for (var i = 1; i <= numRequests; i++) {
        final response = await http.get(Uri.parse('http://localhost:8080'));
        expect(response.statusCode, equals(HttpStatus.ok));
        expect(
          response.body,
          equals('You have requested this route $i time(s).'),
        );
      }
    });
  });
}
