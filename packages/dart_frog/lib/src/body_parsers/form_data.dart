import 'dart:io';

/// Content-Type: application/x-www-form-urlencoded
final formUrlEncodedContentType = ContentType(
  'application',
  'x-www-form-urlencoded',
);

/// Parses the body as form data and returns a `Future<Map<String, String>>`.
/// Throws a [StateError] if the MIME type is not "application/x-www-form-urlencoded"
/// https://fetch.spec.whatwg.org/#ref-for-dom-body-formdata%E2%91%A0
Future<Map<String, String>> parseFormData({
  required Map<String, String> headers,
  required Future<String> Function() body,
}) async {
  final contentType = _extractContentType(headers);
  if (!_isFormUrlEncoded(contentType)) {
    throw StateError(
      '''
Body could not be parsed as form data due to an invalid MIME type.
Expected MIME type: "${formUrlEncodedContentType.mimeType}"
Actual MIME type: "${contentType?.mimeType ?? ''}"
''',
    );
  }

  return Uri.splitQueryString(await body());
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
