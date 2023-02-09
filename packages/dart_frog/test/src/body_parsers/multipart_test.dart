import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog/src/body_parsers/body_parsers.dart';
import 'package:test/test.dart';

void main() {
  group('parseMultipart', () {
    test('throws StateError when content-type header is missing', () async {
      const message = '''
Body could not be parsed as multipart/form-data due to an invalid MIME type.
Expected MIME type: "multipart/form-data"
Actual MIME type: ""
''';
      expect(
        parseMultipart(headers: {}, body: () => const Stream.empty()),
        throwsA(isA<StateError>().having((e) => e.message, 'message', message)),
      );
    });

    test('throws StateError when content-type header is incorrect', () async {
      const message = '''
Body could not be parsed as multipart/form-data due to an invalid MIME type.
Expected MIME type: "multipart/form-data"
Actual MIME type: "application/json"
''';
      expect(
        parseMultipart(
          headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType},
          body: () => const Stream.empty(),
        ),
        throwsA(isA<StateError>().having((e) => e.message, 'message', message)),
      );
    });

    test('returns empty multipart/form-data when body is empty', () async {
      final streamText = Stream.value('\r\n--end\r\n\r\n\r\n--end--\r\n');
      final headerValue = '${multipartContentType.mimeType}; boundary=end';
      expect(
        parseMultipart(
          headers: {HttpHeaders.contentTypeHeader: headerValue},
          body: () => streamText.map((e) => e.codeUnits),
        ),
        completion(isEmpty),
      );
    });

    test(
      'returns populated multipart when body contains a multipart text',
      () async {
        const bodyText = '\r\n--end\r\n'
            'content-disposition: form-data; name="foo" \r\n'
            '\r\nbar\r\n--end--\r\n';
        final headerValue = '${multipartContentType.mimeType}; boundary=end';

        expect(
          parseMultipart(
            headers: {HttpHeaders.contentTypeHeader: headerValue},
            body: () => Stream.value(bodyText).map((e) => e.codeUnits),
          ),
          completion(equals({'foo': 'bar'})),
        );
      },
    );

    test(
      'returns populated multipart when body '
      'contains a multipart text with a file ',
      () async {
        const file = 'test_file.png';
        const contentFile = 'Value of the second field!';
        const bodyText = '\r\n--end\r\n'
            'content-disposition: form-data; name="foo" \r\n'
            '\r\nbar\r\n--end\r\n'
            'content-disposition: form-data; name="file"; filename="$file"\r\n'
            '\r\n$contentFile\r\n--end--\r\n';

        final headerValue = '${multipartContentType.mimeType}; boundary=end';
        final multipartFile = MultipartFile(
          fileContent: Uint8List.fromList(contentFile.codeUnits),
          fileName: file,
        );

        expect(
          parseMultipart(
            headers: {HttpHeaders.contentTypeHeader: headerValue},
            body: () => Stream.value(bodyText).map((e) => e.codeUnits),
          ),
          completion(equals({'foo': 'bar', 'file': multipartFile})),
        );
      },
    );
  });
}
