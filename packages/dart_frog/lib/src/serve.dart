part of '_internal.dart';

/// Starts an [HttpServer] that listens on the specified [address] and
/// [port] and sends requests to [handler].
///
/// Pass [poweredByHeader] to set the default content for "X-Powered-By",
/// pass `null` to omit this header.
/// By default, the header will be:
///
/// `"X-Powered-By": "Dart with package:dart_frog"`
///
/// If a [securityContext] is provided an HTTPS server will be started.
///
/// Enable [shared] to allow additional [HttpServer] objects to bind to the
/// same combination of [HttpServer.address] and [HttpServer.port].
Future<HttpServer> serve(
  Handler handler,
  Object address,
  int port, {
  String? poweredByHeader = 'Dart with package:dart_frog',
  SecurityContext? securityContext,
  bool shared = false,
}) {
  return shelf_io.serve(
    (shelf.Request request) async {
      final response = await handler(RequestContext._(request));
      return response._response;
    },
    address,
    port,
    poweredByHeader: poweredByHeader,
    securityContext: securityContext,
    shared: shared,
  );
}
