part of '_internal.dart';

/// Middleware which prints the time of the request, the elapsed time for the
/// inner handlers, the response's status code and the request URI.
///
/// If [logger] is passed, it's called for each request. The `msg` parameter is
/// a formatted string that includes the request time, duration, request method,
/// and requested path. When an exception is thrown, it also includes the
/// exception's string and stack trace; otherwise, it includes the status code.
/// The `isError` parameter indicates whether the message is caused by an error.
///
/// If [logger] is not passed, the message is just passed to [print].
Middleware requestLogger({
  void Function(String message, bool isError)? logger,
}) {
  return _fromShelfMiddleware(shelf.logRequests(logger: logger));
}

Middleware _fromShelfMiddleware(shelf.Middleware middleware) {
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
