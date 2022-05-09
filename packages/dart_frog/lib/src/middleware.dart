import 'package:dart_frog/dart_frog.dart';

/// Extension on [Handler] which adds support
/// for applying middleware to the request pipeline.
extension HandlerUse on Handler {
  /// Apply [middleware] to the current handler.
  Handler use(Middleware middleware) {
    const pipeline = Pipeline();
    return pipeline.addMiddleware(middleware).addHandler(this);
  }
}
