---
sidebar_position: 1
---

# Routes 🚏

## Overview ✨

In Dart Frog, a route consists of an `onRequest` function (called a route handler) exported from a `.dart` file in the `routes` directory. Each endpoint is associated with a routes file based on its file name. Files named, `index.dart` will correspond to a `/` endpoint.

For example, if you create `routes/hello.dart` that exports an `onRequest` method like below, it will be accessible at `/hello`.

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(body: 'Hello World');
}
```

## Request Context 🔗

All route handlers have access to a `RequestContext` which can be used to access the incoming request as well as dependencies provided to the request context ([see middleware](/docs/basics/middleware)).

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  // Access the incoming request.
  final request = context.request;

  // Return a response.
  return Response(body: 'Hello World');
}
```

## Custom Status Code 🆗

We can customize the status code of the response via the `statusCode` parameter on the `Response` object:

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(statusCode: 204);
}
```

## Returning JSON `{}`

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
Check out [`json_serializable`](https://pub.dev/packages/json_serializable) to automate the `toJson` generation.
:::

:::caution
`json_serializable` uses [`build_runner`](https://pub.dev/packages/build_runner) which expects code to be within the `lib` directory. In order for the code generation step to work, make sure the `User` model below is located somewhere within the top level `lib` directory.

For example:

```
├── lib
│   └── models
│       └── user.dart
└── routes
```

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

## Route Conflicts 💥

When defining routes, it's possible to encounter route conflicts.

A route conflict occurs when more than one route handler resolves to the same endpoint.

For example, given the following file structure:

```
├── routes
│   ├── api
│   │   └── index.dart
│   └── api.dart
```

Both `routes/api/index.dart` and `routes/api.dart` resolve the the `/api` endpoint.

When running the development server via `dart_frog dev`, Dart Frog will report route conflicts while the development server is running. You can resolve the conflicts and hot reload will allow you to continue development without having to restart the server.

```bash
[hotreload] - Application reloaded.

Route conflict detected. `routes/api.dart` and `routes/api/index.dart` both resolve to `/api`.
```

When generating a production build via `dart_frog build`, Dart Frog will report all detected route conflicts and fail the build if one or more route conflicts are detected.

## Rogue Routes 🥷

Similar to route conflicts, it's also possible to run into rogue routes when working with Dart Frog.

A route is considered rogue when it is defined outside of an existing subdirectory with the same name.

For example:

```
├── routes
│   ├── api
│   │   └── example.dart
│   ├── api.dart
```

In the above scenario, `routes/api.dart` is rogue because it is defined outside of the existing `api` directory.

To correct this, `api.dart` should be renamed to `index.dart` and placed within the `api` directory like:

```
├── routes
│   ├── api
│   │   ├── example.dart
│   │   └── index.dart
```

When running the development server via `dart_frog dev`, Dart Frog will report rogue routes while the development server is running. You can resolve the issues and hot reload will allow you to continue development without having to restart the server.

```bash
[hotreload] - Application reloaded.

Rogue route detected. `routes/api.dart` should be renamed to `routes/api/index.dart`.
```

When generating a production build via `dart_frog build`, Dart Frog will report all detected rogue routes and fail the build if one or more rogue routes are detected.
