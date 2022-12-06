import 'package:dart_frog/dart_frog.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart' as shelf_web_socket;
import 'package:web_socket_channel/web_socket_channel.dart';

/// Creates a Dart Frog [Handler] that upgrades HTTP requests to WebSocket
/// connections.
///
/// ```dart
/// import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
///
/// final onRequest = webSocketHandler(
///   (channel, protocol) {
///     // A new connection was established.
///     print('connected');
///     // Subscribe to the stream of messages from the client.
///     channel.stream.listen(
///       (message) {
///         // Handle incoming messages.
///         print('received: $message');
///         // Send outgoing messages to the connected client.
///         channel.sink.add('pong');
///       },
///       // The connection was terminated.
///       onDone: () => print('disconnected'),
///     );
///   },
/// );
/// ```
///
/// Only valid WebSocket upgrade requests are upgraded. If a request doesn't
/// look like a WebSocket upgrade request, a 404 Not Found is returned; if a
/// request looks like an upgrade request but is invalid, a 400 Bad Request is
/// returned; and if a request is a valid upgrade request but has an origin that
/// doesn't match [allowedOrigins] (see below), a 403 Forbidden is returned.
///
/// The [onConnection] must take a [WebSocketChannel] as the first argument
/// and a string for the [WebSocket subprotocol][] as the second
/// argument. The subprotocol is determined by looking at the client's
/// `Sec-WebSocket-Protocol` header and selecting the first entry that also
/// appears in [protocols]. If no subprotocols are shared between the client and
/// the server, `null` will be passed instead and no subprotocol header will be
/// sent to the client which may cause it to disconnect.
///
/// [WebSocket subprotocol]: https://tools.ietf.org/html/rfc6455#section-1.9
///
/// If [allowedOrigins] is passed, browser connections will only be accepted if
/// they're made by a script from one of the given origins. This ensures that
/// malicious scripts running in the browser are unable to fake a WebSocket
/// handshake. Note that non-browser programs can still make connections freely.
/// See also the WebSocket spec's discussion of [origin considerations][].
///
/// [origin considerations]: https://tools.ietf.org/html/rfc6455#section-10.2
///
/// If [pingInterval] is specified, it will get passed to the created
/// channel instance, enabling round-trip disconnect detection.
///
/// This method uses [`package:shelf_web_socket`](https://pub.dev/packages/shelf_web_socket)
/// internally.
Handler webSocketHandler(
  void Function(WebSocketChannel channel, String? protocol) onConnection, {
  Iterable<String>? protocols,
  Iterable<String>? allowedOrigins,
  Duration? pingInterval,
}) {
  return fromShelfHandler(
    shelf_web_socket.webSocketHandler(
      onConnection,
      protocols: protocols,
      allowedOrigins: allowedOrigins,
      pingInterval: pingInterval,
    ),
  );
}
