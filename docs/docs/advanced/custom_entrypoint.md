---
sidebar_position: 1
---

# Custom Server Entrypoint 🎬

Dart Frog supports creating a custom entrypoint in cases where you need fine-grained control over the server initialization or wish to execute code prior to starting the server.

## Creating a Custom Entrypoint ✨

To create a custom entrypoint, simply create a `main.dart` file at the root of your Dart Frog project. The `main.dart` file must expose a top-level `run` method with the following signature:

```dart
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  // 1. Execute any custom code prior to starting the server...

  // 2. Use the provided `handler`, `ip`, and `port` to create a new `HttpServer`.
  // You can also create your own `HttpServer` manually and customize the handler, ip, and port.
  return serve(handler, ip, port);
}
```

The Dart Frog CLI will detect the custom entrypoint and execute your custom `run` method instead of the default implementation.
