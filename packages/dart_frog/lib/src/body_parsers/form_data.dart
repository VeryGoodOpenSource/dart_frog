import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

/// Content-Type: application/x-www-form-urlencoded
final formUrlEncodedContentType = ContentType(
  'application',
  'x-www-form-urlencoded',
);

/// Content-Type: multipart/form-data
final multipartFormDataContentType = ContentType(
  'multipart',
  'form-data',
);

/// Parses the body as form data and returns a `Future<Map<String, dynamic>>`.
/// Throws a [StateError] if the MIME type is not "application/x-www-form-urlencoded" or "multipart/form-data".
/// https://fetch.spec.whatwg.org/#ref-for-dom-body-formdata%E2%91%A0
Future<Map<String, dynamic>> parseFormData({
  required Map<String, String> headers,
  required Future<String> Function() body,
  required Stream<List<int>> Function() bytes,
}) async {
  final contentType = _extractContentType(headers);
  final isFormUrlEncoded = _isFormUrlEncoded(contentType);
  final isMultipartFormData = _isMultipartFormData(contentType);

  if (!isFormUrlEncoded && !isMultipartFormData) {
    throw StateError(
      '''
Body could not be parsed as form data due to an invalid MIME type.
Expected MIME type: "${formUrlEncodedContentType.mimeType}" OR "${multipartFormDataContentType.mimeType}"
Actual MIME type: "${contentType?.mimeType ?? ''}"
''',
    );
  }

  return isFormUrlEncoded
      ? _extractFormUrlEncodedFormData(body: await body())
      : await _extractMultipartFormData(headers: headers, bytes: bytes());
}

ContentType? _extractContentType(Map<String, String> headers) {
  final contentTypeValue = headers[HttpHeaders.contentTypeHeader];
  if (contentTypeValue == null) return null;
  return ContentType.parse(contentTypeValue);
}

bool _isFormUrlEncoded(ContentType? contentType) {
  if (contentType == null) return false;
  return contentType.mimeType == formUrlEncodedContentType.mimeType;
}

bool _isMultipartFormData(ContentType? contentType) {
  if (contentType == null) return false;
  return contentType.mimeType == multipartFormDataContentType.mimeType;
}

Map<String, String> _extractFormUrlEncodedFormData({required String body}) {
  return Uri.splitQueryString(body);
}

Future<Map<String, dynamic>> _extractMultipartFormData({
  required Map<String, String> headers,
  required Stream<List<int>> bytes,
}) async {
  final contentType = headers[HttpHeaders.contentTypeHeader];
  final mediaType = MediaType.parse(contentType!);
  final boundary = mediaType.parameters['boundary'];
  final transformer = MimeMultipartTransformer(boundary!);

  final formData = <String, dynamic>{};

  await for (final part in transformer.bind(bytes)) {
    final contentDisposition = part.headers['Content-Disposition'];
    if (contentDisposition == null) continue;

    // https://github.com/denoland/deno/blob/main/ext/fetch/21_formdata.js#L330
  }

  return formData;
}
