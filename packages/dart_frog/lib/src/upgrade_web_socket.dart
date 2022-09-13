part of '_internal.dart';

/// Upgrade a Http connection to Websocket and return [Response].
FutureOr<Response> upgradeToWebSocket(
  RequestContext context,
  void Function(Socket socket) handler, {
  Iterable<String>? protocols,
  Iterable<String>? allowedOrigins,
  Duration? pingInterval,
}) {
  return fromShelfHandler(
    shelf_web_socket.webSocketHandler(
      (web_socket_channel.WebSocketChannel webSocketChannel) => handler(
        Socket._(webSocketChannel),
      ),
      protocols: protocols,
      allowedOrigins: allowedOrigins,
      pingInterval: pingInterval,
    ),
  )(context);
}
