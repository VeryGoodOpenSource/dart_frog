part of '_internal.dart';

/// Starts an [HttpServer] that listens on the specified [address] and
/// [port] and sends requests to [handler].
Future<HttpServer> serve(Handler handler, Object address, int port) {
  return shelf_io.serve(
    (shelf.Request request) async {
      final response = await handler(RequestContext._(request));
      return response._response;
    },
    address,
    port,
  );
}
