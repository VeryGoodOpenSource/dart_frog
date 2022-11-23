import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('E2E (/projects)', () {
    final contentTypeFormUrlEncodedHeader = {
      HttpHeaders.contentTypeHeader: ContentType(
        'application',
        'x-www-form-urlencoded',
      ).mimeType,
    };

    test('GET /projects responds 405', () async {
      final response = await http.get(
        Uri.parse('http://localhost:8080/projects'),
      );
      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
    });

    test('POST /projects responds with project configuration', () async {
      final response = await http.post(
        Uri.parse('http://localhost:8080/projects'),
        headers: contentTypeFormUrlEncodedHeader,
        body: 'name=my_app&version=3.0.0',
      );
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(
        response.body,
        equals({
          'project_configuration': {'name': 'my_app', 'version': '3.0.0'}
        }),
      );
    });
  });
}
