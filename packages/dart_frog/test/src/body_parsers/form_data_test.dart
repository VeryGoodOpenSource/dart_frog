import 'dart:io';

import 'package:dart_frog/src/body_parsers/form_data.dart';
import 'package:test/test.dart';

void main() {
  group('parseFormData', () {
    test('throws StateError when content-type header is missing', () async {
      const message = '''
Body could not be parsed as form data due to an invalid MIME type.
Expected MIME type: "application/x-www-form-urlencoded"
Actual MIME type: ""
''';
      expect(
        parseFormData(headers: {}, body: () async => ''),
        throwsA(isA<StateError>().having((e) => e.message, 'message', message)),
      );
    });

    test('throws StateError when content-type header is incorrect', () async {
      const message = '''
Body could not be parsed as form data due to an invalid MIME type.
Expected MIME type: "application/x-www-form-urlencoded"
Actual MIME type: "application/json"
''';
      expect(
        parseFormData(
          headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType},
          body: () async => '',
        ),
        throwsA(isA<StateError>().having((e) => e.message, 'message', message)),
      );
    });

    test('returns empty form data when body is empty', () async {
      expect(
        parseFormData(
          headers: {
            HttpHeaders.contentTypeHeader: formUrlEncodedContentType.mimeType
          },
          body: () async => '',
        ),
        completion(isEmpty),
      );
    });

    test(
        'returns populated form data '
        'when body contains single key/value', () async {
      expect(
        parseFormData(
          headers: {
            HttpHeaders.contentTypeHeader: formUrlEncodedContentType.mimeType
          },
          body: () async => 'foo=bar',
        ),
        completion(equals({'foo': 'bar'})),
      );
    });

    test(
        'returns populated form data '
        'when body contains multiple key/values', () async {
      expect(
        parseFormData(
          headers: {
            HttpHeaders.contentTypeHeader: formUrlEncodedContentType.mimeType
          },
          body: () async => 'foo=bar&bar=baz',
        ),
        completion(equals({'foo': 'bar', 'bar': 'baz'})),
      );
    });
  });
}
