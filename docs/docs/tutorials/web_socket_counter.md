---
sidebar_position: 5
title: 🔌 WebSocket Counter
description: Build a real time "Counter" powered by WebSockets.
---

# WebSocket Counter 🔌

:::info
**Difficulty**: 🟠 Intermediate<br/>
**Length**: 30 minutes

Before getting started, [read the Dart Frog prerequisites](/docs/overview#prerequisites) to make sure your development environment is ready.
:::

## Overview

In this tutorial, we're going to build an app that exposes a single endpoint which handles WebSocket connections and maintains a real-time counter which can be incremented and decremented by connected clients.

When we're done, we should be able to connect to the `/ws` endpoint and send or receive messages.

```dart
import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  final channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8080/ws'));
  channel.stream.listen(print);

  channel.sink.add('__increment__');
  channel.sink.add('__decrement__');

  channel.sink.close();
}
```

We should see the following output:

```
0 # initial
1 # increment
0 # decrement
```

## Creating a new app

To create a new Dart Frog app, open your terminal, change to the directory where you'd like to create the app, and run the following command:

```bash
dart_frog create web_socket_counter
```

You should see an output similar to:

```
✓ Creating web_socket_counter (0.1s)
✓ Installing dependencies (1.7s)

Created web_socket_counter at ./web_socket_counter.

Get started by typing:

cd ./web_socket_counter
dart_frog dev
```

:::tip
Install and use the [Dart Frog VS Code extension](https://marketplace.visualstudio.com/items?itemName=VeryGoodVentures.dart-frog) to easily create Dart Frog apps within your IDE.
:::

## Running the development server

You should now have a directory called `web_socket_counter`. Let's change directories into the newly created project:

```bash
cd web_socket_counter
```

Then, run the following command:

```bash
dart_frog dev
```

This will start the development server on port `8080`:

```
✓ Running on http://localhost:8080 (1.3s)
The Dart VM service is listening on http://127.0.0.1:8181/YKEF_nbwOpM=/
The Dart DevTools debugger and profiler is available at: http://127.0.0.1:8181/YKEF_nbwOpM=/devtools/#/?uri=ws%3A%2F%2F127.0.0.1%3A8181%2FYKEF_nbwOpM%3D%2Fws
[hotreload] Hot reload is enabled.
```

Make sure it's working by opening [http://localhost:8080](http://localhost:8080) in your browser or via `cURL`:

```bash
curl --request GET \
  --url http://localhost:8080
```

If everything succeeded, you should see `Welcome to Dart Frog!`.

## Creating the WebSocket Route

Now that we have a running application, let's start by creating a new `ws` route at `routes/ws.dart`:

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(body: 'You have requested /ws');
}
```

We can also delete the root endpoint at `routes/index.dart` since we won't be needing it for this example.

:::tip
Install and use the [Dart Frog VS Code extension](https://marketplace.visualstudio.com/items?itemName=VeryGoodVentures.dart-frog) to easily create new routes within your IDE.
:::

Save the changes and hot reload should kick in ⚡️

```
[hotreload] - Application reloaded.
```

Now if we visit [http://localhost:8080/ws](http://localhost:8080/ws) in the browser or via `cURL`:

```bash
curl --request GET \
  --url http://localhost:8080/ws
```

We should see our new response:

```
You have requested /ws
```

## Adding a WebSocket Handler

Next, we need to upgrade our route handler to handle WebSocket connections. To do this we'll use the [dart_frog_web_socket](https://pub.dev/packages/dart_frog_web_socket) package.

Add the `dart_frog_web_socket` dependency:

```
dart pub add dart_frog_web_socket
```

Now, let's update our route handler at `routes/ws.dart` to use the provided `webSocketHandler` from `dart_frog_web_socket`:

```dart
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

Future<Response> onRequest(RequestContext context) async {
  final handler = webSocketHandler(
    (channel, protocol) {
      // A new client has connected to our server.
      print('connected');

      // Send a message to the client.
      channel.sink.add('hello from the server');

      // Listen for messages from the client.
      channel.stream.listen(
        print,
        // The client has disconnected.
        onDone: () => print('disconnected'),
      );
    },
  );

  return handler(context);
}
```

:::info
For more information, refer to the [WebSocket documentation](/docs/advanced/web_socket).
:::

Save the changes and hot reload should kick in ⚡️

Now we should be able to write a simple script to test the WebSocket connection.

## Establishing a WebSocket Connection

Create a new directory called `example` at the project root and create a `pubspec.yaml`:

```yaml
name: example
publish_to: none

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  web_socket_channel: ^2.4.0
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

  // Listen to messages from the server.
  channel.stream.listen(print);

  // Send a message to the server.
  channel.sink.add('hello from the client');

  // Close the connection.
  channel.sink.close();
}
```

We're using [`package:web_socket_channel`](https://pub.dev/packages/web_socket_channel) to connect to our Dart Frog `/ws` endpoint. We can send messages to the server by calling `add` on the `WebSocketChannel` sink. We can listen to incoming messages by subscribing to the `WebSocketChannel` stream.

With the Dart Frog server still running, open a separate terminal, and run the example script:

```bash
dart example/main.dart
```

We should see the following output on the client:

```
hello from the server
```

On the server we should see the following output:

```
connected
hello from the client
disconnected
```

Awesome! We've configured a WebSocket handler and established a connection to our server 🎉

## Managing the Counter State

Now that we've configured the WebSocket handler, we're going to shift gears and work on creating a component that will manage the state of the counter.

In this example, we're going to use a cubit from the [Bloc Library](https://bloclibrary.dev) to manage the state of our counter because it provides a reactive API which allows us to stream state changes and query the current state at any given point in time. We're going to use [package:broadcast_bloc](https://pub.dev/packages/broadcast_bloc) which allows blocs or cubits to broadcast their state changes to any subscribed stream channels — this will come in handy later on.

Let's add the `broadcast_bloc` dependency:

```
dart pub add broadcast_bloc
```

Then, create a cubit in `lib/counter/cubit/counter_cubit.dart`.

```dart
import 'package:broadcast_bloc/broadcast_bloc.dart';

class CounterCubit extends BroadcastCubit<int> {
  // Create an instance with an initial state of 0.
  CounterCubit() : super(0);

  // Increment the current state.
  void increment() => emit(state + 1);

  // Decrement the current state.
  void decrement() => emit(state - 1);
}
```

In order to access the cubit from our route handler, we'll create a `provider` in `lib/counter/middleware/counter_provider.dart`.

```dart
import 'package:dart_frog/dart_frog.dart';
import 'package:web_socket_counter/counter/counter.dart';

final _counter = CounterCubit();

// Provide the counter instance via `RequestContext`.
final counterProvider = provider<CounterCubit>((_) => _counter);
```

:::info
For more information, refer to the [dependency injection documentation](/docs/basics/dependency-injection).
:::

Let's also create a barrel file which exports all `counter` components in `lib/counter/counter.dart`:

```dart
export 'cubit/counter_cubit.dart';
export 'middleware/counter_provider.dart';
```

## Providing the Counter

We need to use the `counterProvider` in order to have access to it in nested. Create a global piece of middleware (`routes/_middleware.dart`):

```dart
import 'package:dart_frog/dart_frog.dart';
import 'package:web_socket_counter/counter/counter.dart';

Handler middleware(Handler handler) => handler.use(counterProvider);
```

:::info
For more information, refer to the [middleware documentation](/docs/basics/middleware).
:::

:::tip
Install and use the [Dart Frog VS Code extension](https://marketplace.visualstudio.com/items?itemName=VeryGoodVentures.dart-frog) to easily create new middleware within your IDE.
:::

## Using the Counter

We can access the `CounterCubit` instance from our WebSocket handler via `context.read<CounterCubit>()`.

```dart
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:web_socket_counter/counter/counter.dart';

Future<Response> onRequest(RequestContext context) async {
  final handler = webSocketHandler(
    (channel, protocol) {
      // A new client has connected to our server.
      // Subscribe the new client to receive notifications
      // whenever the cubit state changes.
      final cubit = context.read<CounterCubit>()..subscribe(channel);

      // Send the current count to the new client.
      channel.sink.add('${cubit.state}');

      // Listen for messages from the client.
      channel.stream.listen(
        (event) {
          switch (event) {
            // Handle an increment message.
            case '__increment__':
              cubit.increment();
              break;
            // Handle a decrement message.
            case '__decrement__':
              cubit.decrement();
              break;
            // Ignore any other messages.
            default:
              break;
          }
        },
        // The client has disconnected.
        // Unsubscribe the channel.
        onDone: () => cubit.unsubscribe(channel),
      );
    },
  );

  return handler(context);
}
```

First, we subscribe the newly connected client to the `CounterCubit` in order to receive updates whenever the cubit state changes.

Next, we send the current count to the new client via `cubit.state`.

When the client sends a new message, we invoke the `increment`/`decrement` method on the cubit based on the message.

Finally, we unsubscribe the channel when the client disconnects.

:::info
The `subscribe` and `unsubscribe` APIs are exposed by the `BroadcastCubit` super class from `package:broadcast_bloc`.
:::

Be sure to save all the changes and hot reload should kick in ⚡️

```
[hotreload] - Application reloaded.
```

Now we can update our example script in `example/main.dart`:

```dart
import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  final channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8080/ws'));
  channel.stream.listen(print);

  channel.sink.add('__increment__');
  channel.sink.add('__decrement__');

  channel.sink.close();
}
```

Finally, let's run the script:

```
dart example/main.dart
```

We should see the following output:

```
0
1
0
```

:::note
If you restart the server, the count will always be reset to 0 because it is only maintained in memory.
:::

🎉 Congrats, you've created a real-time counter application using Dart Frog. View the [full source code](https://github.com/VeryGoodOpenSource/dart_frog/tree/main/examples/web_socket_counter).
