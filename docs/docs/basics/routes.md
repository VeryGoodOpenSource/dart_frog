---
sidebar_position: 1
---

# Routes 🚏

In Dart Frog, a route consists of an `onRequest` function (called a route handler) exported from a `.dart` file in the `routes` directory. Each endpoint is associated with a routes file based on its file name. Files named, `index.dart` will correspond to a `/` endpoint.

For example, if you create `routes/hello.dart` that exports an `onRequest` method like below, it will be accessible at `/hello`.

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(body: 'Hello World');
}
```

All route handlers have access to a `RequestContext` which can be used to access the incoming request as well as dependencies provided to the request context (see middleware).

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  // Access the incoming request.
  final request = context.request;

  // Return a response.
  return Response(body: 'Hello World');
}
```

We can customize the status code of the response via the `statusCode` parameter on the `Response` object:

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(statusCode: 204);
}
```

In addition, we can return JSON via the `Response.json` constructor:

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: <String, dynamic>{'hello': 'world!'},
  );
}
```

We can also return any Dart object in the `body` of the `Response.json` constructor and it will be serialized correctly as long as it has a `toJson` method that returns a `Map<String, dynamic>`.

:::tip
Check out [json_serializable](https://pub.dev/packages/json_serializable) to automate the `toJson` generation.
:::

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  const User({required this.name, required this.age});

  final String name;
  final int age;

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: User(name: 'Dash', age: 42),
  );
}
```

Route handlers can be synchronous or asynchronous. To convert the above route handlers to async, we just need to update the return type from `Response` to `Future<Response>`. We can add the `async` keyword in order to `await` futures within our handler before returning a `Response`.

```dart
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final result = await _someFuture();
  return Response(body: 'Result is: $result!');
}
```

## Dynamic Routes 🌓

Dart Frog supports dynamic routes. For example, if you create a file called `routes/posts/[id].dart`, then it will be accessible at `/posts/1`, `/posts/2`, etc.

Routing parameters are forwarded to the `onRequest` method as seen below.

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context, String id) {
  return Response(body: 'post id: $id');
}
```
