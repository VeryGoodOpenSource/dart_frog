{{> generated_header }}

import 'package:dart_frog/dart_frog.dart' show HttpMethod;

/// {@template request}
/// A client-side http request.
/// {@endtemplate}
class Request {
  /// {@macro request}
  const Request({
    required this.method,
    this.headers = const {},
    this.body,
  });

  /// {@macro request}
  const Request.delete({Map<String, String>? headers, Object? body})
      : this(
          method: HttpMethod.delete,
          headers: headers ?? const {},
          body: body,
        );

  /// {@macro request}
  const Request.get({Map<String, String>? headers})
      : this(method: HttpMethod.get, headers: headers ?? const {});

  /// {@macro request}
  const Request.head({Map<String, String>? headers})
      : this(method: HttpMethod.head, headers: headers ?? const {});

  /// {@macro request}
  const Request.patch({Map<String, String>? headers, Object? body})
      : this(
          method: HttpMethod.patch,
          headers: headers ?? const {},
          body: body,
        );

  /// {@macro request}
  const Request.post({Map<String, String>? headers, Object? body})
      : this(method: HttpMethod.post, headers: headers ?? const {}, body: body);

  /// {@macro request}
  const Request.put({Map<String, String>? headers, Object? body})
      : this(
          method: HttpMethod.put,
          headers: headers ?? const {},
          body: body,
        );

  /// The corresponding http method.
  final HttpMethod method;

  /// The corresponding headers.
  final Map<String, String> headers;

  /// The corresponding body.
  final Object? body;
}
