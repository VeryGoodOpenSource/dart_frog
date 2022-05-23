import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

/// {@template json_response}
/// A [Response] which includes a json response body.
/// {@endtemplate}
class JsonResponse extends Response {
  /// {@macro json_response}
  JsonResponse({
    super.statusCode,
    Map<String, dynamic>? body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : super(
          body: body != null ? json.encode(body) : null,
          headers: {
            ...headers,
            HttpHeaders.contentTypeHeader: ContentType.json.value,
          },
        );
}
