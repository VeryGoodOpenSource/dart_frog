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
