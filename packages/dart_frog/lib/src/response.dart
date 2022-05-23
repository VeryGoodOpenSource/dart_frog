part of '_internal.dart';

/// {@template response}
/// An HTTP response.
/// {@endtemplate}
class Response {
  /// {@macro response}
  Response({
    int statusCode = 200,
    Object? body,
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
