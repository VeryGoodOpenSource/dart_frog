part of '_internal.dart';

/// Convert from [shelf.Middleware] into [Middleware].
Middleware fromShelfMiddleware(shelf.Middleware middleware) {
  return (handler) {
    return (context) async {
      final response = await middleware(
        (request) async {
          final response = await handler(RequestContext._(request));
          return response._response;
        },
      )(context.request._request);
      return Response._(response);
    };
  };
}

/// Convert from [Middleware] into [shelf.Middleware].
shelf.Middleware toShelfMiddleware(Middleware middleware) {
  return (innerHandler) {
    return (request) async {
      final response = await middleware((context) async {
        final response = await innerHandler(context.request._request);
        return Response._(response);
      })(RequestContext._(request));
      return response._response;
    };
  };
}

/// Convert from a [shelf.Handler] into a [Handler].
Handler fromShelfHandler(shelf.Handler handler) {
  return (context) async {
    final response = await handler(context.request._request);
    return Response._(response);
  };
}

/// Convert from a [Handler] into a [shelf.Handler].
shelf.Handler toShelfHandler(Handler handler) {
  return (request) async {
    final context = RequestContext._(request);
    final response = await handler.call(context);
    return response._response;
  };
}
