part of '_internal.dart';

/// {@template response}
/// An HTTP response.
/// {@endtemplate}
class Response {
  /// Create a [Response] with a string body.
  Response({
    int statusCode = 200,
    String? body,
    Map<String, Object>? headers,
    Encoding? encoding,
  }) : this._(
          shelf.Response(
            statusCode,
            body: body,
            headers: headers,
            encoding: encoding,
          ),
        );

  /// Create a [Response] with a byte array body.
  Response.bytes({
    int statusCode = 200,
    List<int>? body,
    Map<String, Object>? headers,
  }) : this._(
          shelf.Response(
            statusCode,
            body: body,
            headers: headers,
          ),
        );

  /// Create a [Response] with a json body.
  Response.json({
    int statusCode = 200,
    Map<String, dynamic>? body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this(
          statusCode: statusCode,
          body: body != null ? jsonEncode(body) : null,
          headers: {
            ...headers,
            HttpHeaders.contentTypeHeader: ContentType.json.value,
          },
        );

  Response._(this._response);

  final shelf.Response _response;

  /// The HTTP status code of the response.
  int get statusCode => _response.statusCode;

  /// The HTTP headers with case-insensitive keys.
  Map<String, dynamic> get headers => _response.headers;

  /// Returns a [Stream] representing the body.
  Stream<List<int>> bytes() => _response.read();

  /// Returns a Future containing the body as a string.
  Future<String> body() => _response.readAsString();

  /// The body as json (`Map<String, dynamic>`).
  Future<Map<String, dynamic>> json() async {
    return jsonDecode(await _response.readAsString()) as Map<String, dynamic>;
  }

  /// Creates a new [Response] by copying existing values and applying specified
  /// changes.
  Response copyWith({Map<String, Object?>? headers, Object? body}) {
    return Response._(_response.change(headers: headers, body: body));
  }
}
