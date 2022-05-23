import 'package:dart_frog/dart_frog.dart';

/// A function which creates a new [Handler]
/// by wrapping a [Handler].
typedef Middleware = Handler Function(Handler handler);

/// Extension on [Handler] which adds support
/// for applying middleware to the request pipeline.
extension HandlerUse on Handler {
  /// Apply [middleware] to the current handler.
  Handler use(Middleware middleware) {
    const pipeline = Pipeline();
    return pipeline.addMiddleware(middleware).addHandler(this);
  }
}
