---
sidebar_position: 4
title: 🔌 WebSockets
---

# WebSockets 🔌

Dart Frog recently introduced [`package:dart_frog_web_socket`](https://pub.dev/packages/dart_frog_web_socket) to make working with WebSockets easier.

:::info
We added WebSocket support as a separate package to keep the Dart Frog package lightweight, containing only core functionality. In the future, we may add additional packages in order to extend the Dart Frog ecosystem without bloating the core.
:::

## Installation

To get started, add the `dart_frog_web_socket` package as a dependency to your existing Dart Frog project:

```sh
dart pub add dart_frog_web_socket
```

## Creating a WebSocket Handler

We can use the `webSocketHandler` from `package:dart_frog_web_socket` to manage WebSocket connections.

You can either create a new route handler or integrate with an existing handler. For simplicity, we'll first take a look at adding a new route handler specifically for WebSocket connections.

Start by creating a new route, `routes/ws.dart`:

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response();
}
```

Next, instead of handling the request directly, we can create a WebSocket handler:

```dart
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

Future<Response> onRequest(RequestContext context) async {
  final handler = webSocketHandler((channel, protocol) {
    // TODO: react to new connections.
  });
  return handler(context);
}
```

:::note
We need to refactor the request handler to be `async` and return a `Future<Response>` when using the `webSocketHandler`.
:::

The `webSocketHandler` will handle upgrading `HTTP` requests to WebSocket connections and provides an `onConnection` callback which exposes the `WebSocketChannel` as well as an optional subprotocol.

## Receiving Messages from the Client

Next, we can subscribe to the stream of messages exposed by the `WebSocketChannel`:

```dart
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

Future<Response> onRequest(RequestContext context) async {
  final handler = webSocketHandler((channel, protocol) {
    channel.stream.listen((message) {
      // Handle incoming client messages.
      print(message);
    });
  });
  return handler(context);
}
```

For simplicity, we are just printing all messages sent by connected clients.

Before moving on, let's verify that a client is able to establish a connection and send a message to our server. To do this, we'll create a simple client in Dart.

## Sending Messages from the Client

Create a new directory called `example` at the project root and create a `pubspec.yaml`:

```yaml
name: example
publish_to: none

environment:
  sdk: '>=2.18.0 <3.0.0'

dependencies:
  web_socket_channel: ^2.0.0
```

Next, install the dependencies:

```sh
dart pub get
```

Now, create a `main.dart` with the following contents:

```dart
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  // Connect to the remote WebSocket endpoint.
  final uri = Uri.parse('ws://localhost:8080/ws');
  final channel = WebSocketChannel.connect(uri);

  // Send a message to the server.
  channel.sink.add('hello');
}
```

We're using [`package:web_socket_channel`](https://pub.dev/packages/web_socket_channel) to connect to our Dart Frog `/ws` endpoint. We can then send messages to the server by calling `add` on the `WebSocketChannel` sink.

We can run our Dart Frog dev server now:

```sh
dart_frog dev
```

:::note
Be sure to run `dart_frog dev` from the project root.
:::

Once the server is running in a new terminal, we can run our example client to test the connection:

```sh
dart example/main.dart
```

We should see the message we sent in our server logs:

```
✓ Running on http://localhost:8080 (1.3s)
The Dart VM service is listening on http://127.0.0.1:8181/YKEF_nbwOpM=/
The Dart DevTools debugger and profiler is available at: http://127.0.0.1:8181/YKEF_nbwOpM=/devtools/#/?uri=ws%3A%2F%2F127.0.0.1%3A8181%2FYKEF_nbwOpM%3D%2Fws
[hotreload] Hot reload is enabled.
hello
```

## Sending Messages from the Server

Now, let's send a message back to the client from the server. We can do that by adding a message to the channel sink on the server just like we previously did on the client.

```dart
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

Future<Response> onRequest(RequestContext context) async {
  final handler = webSocketHandler((channel, protocol) {
    channel.stream.listen((message) {
      // Handle incoming client messages.
      print(message);
    });

    // Send a message back to the client.
    channel.sink.add('hi');
  });
  return handler(context);
}
```

## Receiving Messages from the Server

Lastly, we need to update the client code to subscribe to messages from the server.

```dart
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  // Connect to the remote WebSocket endpoint.
  final uri = Uri.parse('ws://localhost:8080/ws');
  final channel = WebSocketChannel.connect(uri);

  // Send a message to the server.
  channel.sink.add('hello');

  // Subscribe to messages from the server.
  channel.stream.listen((message) {
    print(message);
  });
}
```

Once we save all the changes and let the server hot reload, we can run the client code again:

```sh
dart example/main.dart
```

And we should see the following output:

**Server**

```sh
[hotreload] Hot reload is enabled.
hello
```

**Client**

```sh
hi
```

## Simplifying Things Further

To make things even simpler, we can refactor the route handler implementation in cases where the route is only managing WebSocket connections:

```dart
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

Handler get onRequest {
  return webSocketHandler((channel, protocol) {
    channel.stream.listen((message) {
      // Handle incoming client messages.
      print(message);
    });

    // Send a message back to the client.
    channel.sink.add('hi');
  });
}
```

## Conclusion

That's it! 🎉

We've successfully established a WebSocket connection between the Dart Frog server and a client. We've also demonstrated how messages can be streamed between a server and one or more clients.
