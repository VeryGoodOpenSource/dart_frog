---
sidebar_position: 3
---

# Dependency Injection 💉

Middleware can also be used to provide dependencies to a `RequestContext` via a `provider`.

`provider` is a type of middleware that can create and provide an instance of type `T` to the request context. The `create` callback is called lazily and the injected `RequestContext` can be used to perform additional lookups to access values provided upstream.

In the following example, we'll use a `provider` to inject a `String` into our request context.

```dart
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(provider<String>((context) => 'Welcome to Dart Frog!'));
}
```

We can later access the provided via from within a route handler using `context.read<T>()`:

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final greeting = context.read<String>();
  return Response(body: greeting);
}
```
