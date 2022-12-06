# Example

Use `webSocketHandler` to manage `WebSocket` connections in a Dart Frog route handler.

```dart
// routes/ws.dart
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

Handler get onRequest {
  return webSocketHandler(
    (channel, protocol) {
      // A new connection was established.
      print('connected');
      // Subscribe to the stream of messages from the client.
      channel.stream.listen(
        (message) {
          // Handle incoming messages.
          print('received: $message');
          // Send outgoing messages to the connected client.
          channel.sink.add('pong');
        },
        // The connection was terminated.
        onDone: () => print('disconnected'),
      );
    },
  );
}
```

Connect a client to the remote `WebSocket` endpoint.

```dart
// main.dart
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  // Connect to the remote WebSocket endpoint.
  final uri = Uri.parse('ws://localhost:8080/ws');
  final channel = WebSocketChannel.connect(uri);

  // Listen to incoming messages from the server.
  channel.stream.listen(print);

  // Send messages to the server.
  channel.sink.add('ping');
}
```
