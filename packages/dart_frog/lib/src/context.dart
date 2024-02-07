part of '_internal.dart';

/// {@template context}
/// An object representing a request-specific context.
/// {@endtemplate}
class RequestContext {
  RequestContext._(shelf.Request request) : request = Request._(request);

  /// The associated [Request].
  final Request request;

  /// Provide the value returned by [create] to the respective
  /// request context.
  RequestContext provide<T extends Object?>(T Function() create) {
    return RequestContext._(
      request._request.change(
        context: {...request._request.context, '$T': create},
      ),
    );
  }

  /// Lookup an instance of [T] from the [request] context.
  ///
  /// A [StateError] is thrown if [T] is not available within the
  /// provided [request] context.
  T read<T>() {
    final value = request._request.context['$T'];
    if (value == null) {
      throw StateError(
        '''
context.read<$T>() called with a request context that does not contain a $T.

This can happen if $T was not provided to the request context:
  ```dart
  // _middleware.dart
  Handler middleware(Handler handler) {
    return handler.use(provider<T>((context) => $T());
  }
  ```
''',
      );
    }
    return (value as T Function())();
  }

  /// Get URL parameters captured by the [Router.mount].
  /// They can be accessed from inside the mounted routes.
  Map<String, String> get mountedParams {
    final p = request._request.context['dart_frog/mountedParams'];
    if (p is Map<String, String>) {
      return UnmodifiableMapView(p);
    }
    return _emptyParams;
  }
}
