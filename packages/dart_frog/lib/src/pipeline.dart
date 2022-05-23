part of '_internal.dart';

/// {@template pipeline}
/// A helper that makes it easy to compose a set of [Middleware] and a
/// [Handler].
/// {@endtemplate}
class Pipeline {
  /// {@macro pipeline}
  const Pipeline() : this._(const shelf.Pipeline());

  const Pipeline._(this._pipeline);

  final shelf.Pipeline _pipeline;

  /// Returns a new [Pipeline] with [middleware] added to the existing set of
  /// [Middleware].
  ///
  /// [middleware] will be the last [Middleware] to process a request and
  /// the first to process a response.
  Pipeline addMiddleware(Middleware middleware) {
    return Pipeline._(
      _pipeline.addMiddleware((innerHandler) {
        return (request) async {
          final response = await middleware(
            (context) async {
              final response = await innerHandler(context.request._request);
              return Response._(response);
            },
          )(RequestContext._(request));
          return response._response;
        };
      }),
    );
  }

  /// Returns a new [Handler] with [handler] as the final processor of a
  /// [Request] if all of the middleware in the pipeline have passed the request
  /// through.
  Handler addHandler(Handler handler) {
    return (context) async {
      final response = await _pipeline.addHandler((request) async {
        final context = RequestContext._(request);
        final response = await handler(context);
        return response._response;
      })(context.request._request);
      return Response._(response);
    };
  }

  /// Exposes this pipeline of [Middleware] as a single middleware instance.
  Middleware get middleware => addHandler;
}
