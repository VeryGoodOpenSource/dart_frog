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

  /// Create a [Response] with a stream of bytes.
  Response.stream({
    int statusCode = 200,
    Stream<List<int>>? body,
    Map<String, Object>? headers,
  }) : this._(
          shelf.Response(
            statusCode,
            body: body,
            headers: headers,
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

  /// Create a [Response] with a json encoded body.
  Response.json({
    int statusCode = 200,
    Object? body = const <String, dynamic>{},
    Map<String, Object> headers = const <String, Object>{},
  }) : this(
          statusCode: statusCode,
          body: body != null ? jsonEncode(body) : null,
          headers: {
            ...headers,
            HttpHeaders.contentTypeHeader: ContentType.json.value,
          },
        );

  /// Create a 400 Bad Request [Response].
  Response.badRequest({
    Object? body,
    Map<String, Object>? headers,
    Encoding? encoding,
    Map<String, Object>? context,
  }) : this._(
          shelf.Response.badRequest(
            body: body,
            headers: headers,
            encoding: encoding,
            context: context,
          ),
        );

  /// Create a 403 Forbidden [Response].
  Response.forbidden(
    Object? body, {
    Map<String, Object>? headers,
    Encoding? encoding,
    Map<String, Object>? context,
  }) : this._(
          shelf.Response.forbidden(
            body,
            headers: headers,
            encoding: encoding,
            context: context,
          ),
        );

  /// Create a 302 Found [Response].
  Response.found(
    Object location, {
    Object? body,
    Map<String, Object>? headers,
    Encoding? encoding,
    Map<String, Object>? context,
  }) : this._(
          shelf.Response.found(
            location,
            body: body,
            headers: headers,
            encoding: encoding,
            context: context,
          ),
        );

  /// Create a 500 Internal Server Error [Response].
  Response.internalServerError({
    Object? body,
    Map<String, Object>? headers,
    Encoding? encoding,
    Map<String, Object>? context,
  }) : this._(
          shelf.Response.internalServerError(
            body: body,
            headers: headers,
            encoding: encoding,
            context: context,
          ),
        );

  /// Create a 301 Moved Permanently [Response].
  Response.movedPermanently(
    Object location, {
    Object? body,
    Map<String, Object>? headers,
    Encoding? encoding,
    Map<String, Object>? context,
  }) : this._(
          shelf.Response.movedPermanently(
            location,
            body: body,
            headers: headers,
            encoding: encoding,
            context: context,
          ),
        );

  /// Create a 404 Not Found [Response].
  Response.notFound(
    Object? body, {
    Map<String, Object>? headers,
    Encoding? encoding,
    Map<String, Object>? context,
  }) : this._(
          shelf.Response.notFound(
            body,
            headers: headers,
            encoding: encoding,
            context: context,
          ),
        );

  /// Create a 304 Not Modified [Response].
  Response.notModified({
    Map<String, Object>? headers,
    Map<String, Object>? context,
  }) : this._(
          shelf.Response.notModified(
            headers: headers,
            context: context,
          ),
        );

  /// Create a 200 OK [Response].
  Response.ok(
    Object? body, {
    Map<String, Object>? headers,
    Encoding? encoding,
    Map<String, Object>? context,
  }) : this._(
          shelf.Response.ok(
            body,
            headers: headers,
            encoding: encoding,
            context: context,
          ),
        );

  /// Create a 303 See Other [Response].
  Response.seeOther(
    Object location, {
    Object? body,
    Map<String, Object>? headers,
    Encoding? encoding,
    Map<String, Object>? context,
  }) : this._(
          shelf.Response.seeOther(
            location,
            body: body,
            headers: headers,
            encoding: encoding,
            context: context,
          ),
        );

  /// Create a 401 Unauthorized [Response].
  Response.unauthorized(
    Object? body, {
    Map<String, Object>? headers,
    Encoding? encoding,
    Map<String, Object>? context,
  }) : this._(
          shelf.Response.unauthorized(
            body,
            headers: headers,
            encoding: encoding,
            context: context,
          ),
        );

  Response._(this._response);

  shelf.Response _response;

  /// The HTTP status code of the response.
  int get statusCode => _response.statusCode;

  /// The HTTP headers with case-insensitive keys.
  /// The returned map is unmodifiable.
  Map<String, String> get headers => _response.headers;

  /// Returns a [Stream] representing the body.
  Stream<List<int>> bytes() => _response.read();

  /// Returns a [Future] containing the body as a [String].
  Future<String> body() async {
    const responseBodyKey = 'dart_frog.response.body';
    final bodyFromContext =
        _response.context[responseBodyKey] as Completer<String>?;
    if (bodyFromContext != null) return bodyFromContext.future;

    final completer = Completer<String>();
    try {
      _response = _response.change(
        context: {..._response.context, responseBodyKey: completer},
      );
      completer.complete(await _response.readAsString());
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
    }

    return completer.future;
  }

  /// Returns a [Future] containing the form data as a [Map].
  Future<FormData> formData() {
    return parseFormData(headers: headers, body: body, bytes: bytes);
  }

  /// Returns a [Future] containing the body text parsed as a json object.
  /// This object could be anything that can be represented by json
  /// e.g. a map, a list, a string, a number, a bool...
  Future<dynamic> json() async => jsonDecode(await body());

  /// Creates a new [Response] by copying existing values and applying specified
  /// changes.
  Response copyWith({Map<String, Object?>? headers, Object? body}) {
    return Response._(_response.change(headers: headers, body: body));
  }
}
