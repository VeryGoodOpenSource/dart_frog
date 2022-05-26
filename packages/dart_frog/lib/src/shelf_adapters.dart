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

/// Convert from a [shelf.Handler] into a [Handler].
Handler fromShelfHandler(shelf.Handler handler) {
  return (context) async {
    final response = await handler(context.request._request);
    return Response._(response);
  };
}
