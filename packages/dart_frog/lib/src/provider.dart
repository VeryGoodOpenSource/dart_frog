import 'package:dart_frog/dart_frog.dart';

/// Provide a value to the current handler by calling [create].
Middleware provider<T extends Object>(T Function() create) {
  return (innerHandler) {
    return (request) {
      return innerHandler(request.provide(create));
    };
  };
}

/// Lookup an instance of [T] from context.
///
/// A [StateError] is thrown if [T] is not available within the
/// provided [request] context.
T read<T>(Request request) {
  final value = request.context['$T'];
  if (value == null) {
    throw StateError(
      '''
read<$T>() called with a request context that does not contain a $T.

This can happen if $T was not provided to the reqquest context:
  ```dart
  // _middleware.dart
  Handler middleware(Handler handler) {
    return handler.provide(() => $T());
  }
  ```
''',
    );
  }
  return (value as T Function())();
}

/// Extension on [Request] which adds the ability to provide
/// a value to the request context.
extension ProvideRequest on Request {
  /// Provide the value returned by [create] to the respective
  /// request context.
  Request provide<T extends Object>(T Function() create) {
    return change(context: {...context, '$T': create});
  }
}
