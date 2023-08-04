import 'dart:async';

import 'package:dart_frog/dart_frog.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockRequestContext extends Mock implements RequestContext {}

/// {@template test_request}
/// A model used to create a dart frog [Request] in a test.
/// {@endtemplate}
class TestRequest {
  /// {@macro test_request}
  TestRequest({
    required this.path,
    this.basePath = 'https://test.com',
    this.method = HttpMethod.get,
    this.headers,
    this.body,
  });

  /// The route path.
  final String path;

  /// The base path of the request.
  final String basePath;

  /// The request method.
  final HttpMethod method;

  /// The request headers.
  final Map<String, String>? headers;

  /// The request url.
  final Object? body;

  /// Converts this [TestRequest] to a [Request].
  Request toRequest() {
    return Request(
      method.name.toUpperCase(),
      Uri.parse('$basePath$path'),
      headers: headers,
      body: body,
    );
  }
}

/// Helper class for testing Dart Frog handlers.
class DartFrogTester {
  DartFrogTester._({
    required FutureOr<Response> Function(RequestContext request) onRequest,
    required Request request,
  })  : _request = request,
        _onRequest = onRequest,
        _requestContext = _MockRequestContext();

  final FutureOr<Response> Function(RequestContext request) _onRequest;

  final Request _request;

  final _MockRequestContext _requestContext;

  /// Mocks a dependency of the type [T].
  void mockDependency<T>(T dependency) {
    when(() => _requestContext.read<T>()).thenReturn(dependency);
  }

  /// Runs the request returning the response.
  FutureOr<Response> response() {
    when(() => _requestContext.request).thenReturn(_request);

    return _onRequest(_requestContext);
  }
}

/// A test that can be used to test a Dart Frog handler.
@isTest
void testRouteHandler(
  String message,
  FutureOr<Response> Function(RequestContext request) onRequest,
  TestRequest request,
  FutureOr<void> Function(DartFrogTester tester) testFn, {
  Timeout? timeout,
  Object? skip,
  Object? tags,
  Map<String, dynamic>? onPlatform,
  int? retry,
}) {
  test(
    '${request.method.name.toUpperCase()} ${request.path}: $message',
    timeout: timeout,
    skip: skip,
    tags: tags,
    onPlatform: onPlatform,
    retry: retry,
    () async {
      final tester = DartFrogTester._(
        onRequest: onRequest,
        request: request.toRequest(),
      );

      await testFn(tester);
    },
  );
}
