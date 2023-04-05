---
sidebar_position: 2
title: 🛫 Custom Init Method
---

# Custom Init Method 🛫

Dart Frog supports creating a custom entrypoint as shown in the [Custom Entrypoint docs](/docs/advanced/custom_entrypoint) but that will run every time the server hot reloads. In cases where you want to initialize something only on server start, like setting up a database connection, you can use the `init` method.

## Creating a Custom Init Method ✨

To create a custom init method, simply create a `main.dart` file at the root of your Dart Frog project.

:::warning
Keep in mind that the `main.dart` file must expose a top-level `run` as mentioned in the [Custom Entrypoint docs](/docs/advanced/custom_entrypoint).
:::

Add the following top-level `init` method to the `main.dart` file:

```dart
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Future<void> init(InternetAddress ip, int port) async {
  // Any code initialized within this method will only run on server start, any hot reloads
  // afterwards will not trigger this method until a hot restart.
}

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
    ...
}
```

The Dart Frog CLI will detect the `init` method and execute it on server start.
