import 'package:shelf/shelf.dart';

/// Extension on [Handler] which adds support
/// for providing values to the request context.
extension HandlerProvide on Handler {
  /// Provide a value to the current handler by calling [create].
  Handler provide<T extends Object>(T Function() create) {
    return (request) {
      return this(
        request.change(context: {...request.context, '$T': create}),
      );
    };
  }
}

/// Extension on [Request] which adds support
/// for accessing values from the request context.
extension RequestResolve on Request {
  /// Lookup an instance of [T] from context.
  T resolve<T>() {
    final value = context['$T'];
    if (value == null) {
      throw StateError(
        '''
request.resolve<$T>() called with a request context that does not contain a $T.

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
}
