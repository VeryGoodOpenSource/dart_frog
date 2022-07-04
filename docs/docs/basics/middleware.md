---
sidebar_position: 2
---

# Middleware 🍔

Middleware in Dart Frog allows you to execute code before and after a request is processed. You can modify the inbound request and outbound responses, provide dependencies, and more!

In Dart Frog, a piece of middleware consists of a `middleware` function exported from a `_middleware.dart` file within a subdirectory of the `routes` folder. There can only ever be one piece of middleware per route directory with `routes/_middleware.dart` being middleware that is executed for all inbound requests.

```dart
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return (context) async {
    // Execute code before request is handled.

    // Forward the request to the respective handler.
    final response = await handler(context);

    // Execute code after request is handled.

    // Return a response.
    return response;
  };
}
```

We can chain built-in middleware, such as the `requestLogger` middleware via the `use` API. For example, if we create `routes/_middleware.dart` with the following contents, we will automatically log all requests to our server.

```dart
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler.use(requestLogger());
}
```
