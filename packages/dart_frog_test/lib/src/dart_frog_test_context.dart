import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';

class _MockRequestContext extends Mock implements RequestContext {}

/// {@template dart_frog_test_context}
/// A context used to test Dart Frog handlers.
/// {@endtemplate}
class DartFrogTestContext {
  /// {@macro dart_frog_test_context}
  DartFrogTestContext({
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

  /// The request body.
  final Object? body;

  final _requestContext = _MockRequestContext();

  /// Provides a dependency of the type [T] to the request context.
  void provide<T>(T dependency) =>
      when(() => _requestContext.read<T>()).thenReturn(dependency);

  /// Returns the mocked request context.
  RequestContext get context {
    final request = Request(
      method.name.toUpperCase(),
      Uri.parse('$basePath$path'),
      headers: headers,
      body: body,
    );

    when(() => _requestContext.request).thenReturn(request);

    return _requestContext;
  }
}
