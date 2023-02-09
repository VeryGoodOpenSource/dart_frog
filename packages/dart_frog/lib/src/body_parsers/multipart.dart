import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_frog/dart_frog.dart';
import 'package:mime/mime.dart';
import 'package:string_scanner/string_scanner.dart';

/// Content-Type: multipart/form-data
final multipartContentType = ContentType(
  'multipart',
  'form-data',
);

final _scanWhitespace = RegExp(r'(?:(?:\r\n)?[ \t]+)*');
final _expectedToken = RegExp(r'[^()<>@,;:"\\/[\]?={} \t\x00-\x1F\x7F]+');
final _quotedString = RegExp(r'"(?:[^"\x00-\x1F\x7F]|\\.)*"');

/// Parses the body as multipart form data and returns a
/// `Future<Map<String, dynamic>>`.
/// Throws a [StateError] if the MIME type is not "multipart/form-data"
/// https://fetch.spec.whatwg.org/#ref-for-dom-body-formdata%E2%91%A0
Future<Map<String, dynamic>> parseMultipart({
  required Map<String, String> headers,
  required Stream<List<int>> Function() body,
}) async {
  final contentType = _extractContentType(headers);
  if (!_isMultipart(contentType)) {
    throw StateError(
      '''
Body could not be parsed as multipart/form-data due to an invalid MIME type.
Expected MIME type: "${multipartContentType.mimeType}"
Actual MIME type: "${contentType?.mimeType ?? ''}"
''',
    );
  }

  return <String, dynamic>{
    await for (final data in _multipart(headers, body()))
      data.name: data.filename != null
          ? MultipartFile(
              fileContent: await data.part.readBytes(),
              fileName: data.filename!,
              contentType: data.part.headers['content-type'],
            )
          : await data.part.readString(),
  };
}

ContentType? _extractContentType(Map<String, String> headers) {
  final contentTypeValue = headers[HttpHeaders.contentTypeHeader];
  if (contentTypeValue == null) return null;
  return ContentType.parse(contentTypeValue);
}

bool _isMultipart(ContentType? contentType) {
  if (contentType == null) return false;
  return contentType.mimeType == multipartContentType.mimeType;
}

Map<String, String>? _parseContentDisposition(String header) {
  final scanner = StringScanner(header)
    ..scan(_scanWhitespace)
    ..expect(_expectedToken);

  if (scanner.lastMatch![0] != multipartContentType.subType) {
    return null;
  }

  final params = <String, String>{};
  while (scanner.scan(';')) {
    scanner
      ..scan(_scanWhitespace)
      ..scan(_expectedToken);

    final key = scanner.lastMatch![0]!;
    scanner
      ..expect('=')
      ..expect(_quotedString, name: 'quoted string');

    final string = scanner.lastMatch![0]!;
    final value = string
        .substring(1, string.length - 1)
        .replaceAllMapped(RegExp(r'\\(.)'), (match) => match[1]!);

    scanner.scan(_scanWhitespace);
    params[key] = value;
  }

  scanner.expectDone();
  return params;
}

Stream<_FormData> _multipart(
  Map<String, String> headers,
  Stream<List<int>> body,
) {
  return _parts(headers, body)
      .map((part) {
        final rawDisposition = part.headers['content-disposition'];
        if (rawDisposition == null) return null;

        final formDataParams = _parseContentDisposition(rawDisposition);
        if (formDataParams == null) return null;

        final name = formDataParams['name'];
        if (name == null) return null;

        return _FormData(name, formDataParams['filename'], part);
      })
      .where((data) => data != null)
      .cast();
}

Stream<_Multipart> _parts(Map<String, String> headers, Stream<List<int>> body) {
  final contentType = _extractContentType(headers)!;
  final boundary = contentType.parameters['boundary'];
  return MimeMultipartTransformer(boundary!).bind(body).map(_Multipart.new);
}

class _Multipart extends MimeMultipart {
  _Multipart(this._inner)
      : headers = _inner.headers.map((k, v) => MapEntry(k.toLowerCase(), v));

  final MimeMultipart _inner;

  @override
  final Map<String, String> headers;

  Future<Uint8List> readBytes() async {
    final builder = BytesBuilder();
    await forEach(builder.add);
    return builder.takeBytes();
  }

  Future<String> readString([Encoding? encoding]) {
    encoding ??= utf8;
    return encoding.decodeStream(this);
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _inner.listen(
      onData,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
  }
}

class _FormData {
  _FormData(this.name, this.filename, this.part);

  final String name;

  final String? filename;

  final _Multipart part;
}
