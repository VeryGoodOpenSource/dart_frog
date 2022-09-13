part of '_internal.dart';

/// {@template request}
/// An Web Socket.
/// {@endtemplate}
class Socket {
  /// Create a web socket from [web_socket_channel.WebSocketChannel]
  Socket._(this._webSocketChannel);

  final web_socket_channel.WebSocketChannel _webSocketChannel;

  /// Listen data from Client Socket
  StreamSubscription<dynamic> listen(
    void Function(dynamic)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _webSocketChannel.stream.listen(
      onData,
      onError: onError,
      cancelOnError: cancelOnError,
      onDone: onDone,
    );
  }

  /// Send data to Client Socket
  void send(dynamic data) {
    _webSocketChannel.sink.add(data);
  }

  /// Return a [web_socket_channel.WebSocketChannel] instance
  web_socket_channel.WebSocketChannel get channel => _webSocketChannel;
}
