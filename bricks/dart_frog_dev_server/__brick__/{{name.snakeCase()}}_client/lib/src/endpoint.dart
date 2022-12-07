import 'package:dart_frog/dart_frog.dart' show HttpMethod, Response;
import 'package:http/http.dart' as http;

import './request.dart';

/// {@template endpoint}
/// An API endpoint.
/// {@endtemplate}
class Endpoint {
  /// {@macro endpoint}
  const Endpoint(this._uri, this._client);

  final Uri _uri;
  final http.Client _client;

  /// {@macro endpoint}
  Future<Response> delete({Map<String, String>? headers, Object? body}) {
    return _request(Request.delete(headers: headers, body: body));
  }

  /// {@macro endpoint}
  Future<Response> get({Map<String, String>? headers}) {
    return _request(Request.get(headers: headers));
  }

  /// {@macro endpoint}
  Future<Response> head({Map<String, String>? headers}) {
    return _request(Request.head(headers: headers));
  }

  /// {@macro endpoint}
  Future<Response> patch({Map<String, String>? headers, Object? body}) {
    return _request(Request.patch(headers: headers, body: body));
  }

  /// {@macro endpoint}
  Future<Response> post({Map<String, String>? headers, Object? body}) {
    return _request(Request.post(headers: headers, body: body));
  }

  /// {@macro endpoint}
  Future<Response> put({Map<String, String>? headers, Object? body}) {
    return _request(Request.put(headers: headers, body: body));
  }

  /// {@macro endpoint}
  Future<Response> _request(Request request) async {
    late final http.Response response;
    switch (request.method) {
      case HttpMethod.delete:
        response = await _client.delete(
          _uri,
          headers: request.headers,
          body: request.body,
        );
        break;
      case HttpMethod.get:
        response = await _client.get(
          _uri,
          headers: request.headers,
        );
        break;
      case HttpMethod.head:
        response = await _client.head(
          _uri,
          headers: request.headers,
        );
        break;
      case HttpMethod.patch:
        response = await _client.patch(
          _uri,
          headers: request.headers,
          body: request.body,
        );
        break;
      case HttpMethod.post:
        response = await _client.post(
          _uri,
          headers: request.headers,
          body: request.body,
        );
        break;
      case HttpMethod.put:
        response = await _client.put(
          _uri,
          headers: request.headers,
          body: request.body,
        );
        break;
      case HttpMethod.options:
        throw UnsupportedError('Unsupported HttpMethod: ${request.method}');
    }

    return Response(
      statusCode: response.statusCode,
      body: response.body,
      headers: response.headers,
    );
  }
}
