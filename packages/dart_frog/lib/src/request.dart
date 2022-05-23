part of '_internal.dart';

/// {@template request}
/// An HTTP request.
/// {@endtemplate}
class Request {
  /// {@template request}
  Request(
    String method,
    Uri uri, {
    String? protocolVersion,
    Map<String, Object>? headers,
    Object? body,
    Encoding? encoding,
  }) : this._(
          shelf.Request(
            method,
            uri,
            protocolVersion: protocolVersion,
            headers: headers,
            body: body,
            encoding: encoding,
          ),
        );

  Request._(this._request);

  final shelf.Request _request;

  /// The requested url relative to the current handler path.
  Uri get url => _request.url;

  /// The original requested [Uri].
  Uri get uri => _request.requestedUri;

  /// The HTTP headers with case-insensitive keys.
  Map<String, dynamic> get headers => _request.headers;

  /// The [HttpMethod] associated with the request.
  HttpMethod get method {
    return HttpMethod.values.firstWhere((m) => m.value == _request.method);
  }

  /// Returns a [Stream] representing the body.
  Stream<List<int>> get body => _request.read();

  /// The body as json (`Map<String, dynamic>`).
  Future<Map<String, dynamic>> json() async {
    return jsonDecode(await _request.readAsString()) as Map<String, dynamic>;
  }

  /// Creates a new [Request] by copying existing values and applying specified
  /// changes.
  Request copyWith({
    Map<String, Object?>? headers,
    String? path,
    Object? body,
  }) {
    return Request._(_request.change(headers: headers, path: path, body: body));
  }
}
