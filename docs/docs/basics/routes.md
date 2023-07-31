---
sidebar_position: 1
title: 🚏 Routes
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

## Creating Routes

Managing routes in Dart Frog is essentially as simple as managing the file structure under `/routes`. To help on the creation of routes, Dart Frog provides a CLI command to generate a new route.

```shell
# will create routes/hello.dart
dart_frog new route "/hello"
```

## Requests 📥

All route handlers have access to information regarding the inbound request. In this section, we'll take a look at various ways in which we can interact with the inbound request.

### Request Context

All route handlers have access to a `RequestContext` which can be used to access the incoming request as well as dependencies provided to the request context ([see middleware](/docs/basics/middleware)).

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  // Access the incoming request.
  final request = context.request;

  // Do stuff with the incoming request...

  // Return a response.
  return Response(body: 'Hello World');
}
```

### HTTP Method

A single route handler is responsible for handling inbound requests with any HTTP method. The HTTP method of the inbound request can be accessed via `context.request.method`.

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  // Access the incoming request.
  final request = context.request;

  // Access the HTTP method.
  final method = request.method.value;

  return Response(body: 'This is a $method request.');
}
```

We can make a `GET` request to the above handler and we should see:

```
curl --request GET --url http://localhost:8080

This is a GET request.
```

We can make a `POST` request to the above handler and we should see:

```
curl --request POST --url http://localhost:8080

This is a POST request.
```

### Headers

We can access request headers via `context.request.headers`.

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  // Access the incoming request.
  final request = context.request;

  // Access the headers as a `Map<String, String>`.
  final headers = request.headers;

  // Do something with the headers...

  return Response(body: 'Hello World');
}
```

### Query Parameters

We can access query parameters via `context.request.uri.queryParameters`.

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  // Access the incoming request.
  final request = context.request;

  // Access the query parameters as a `Map<String, String>`.
  final params = request.uri.queryParameters;

  // Get the value for the key `name`.
  // Default to `there` if there is no query parameter.
  final name = params['name'] ?? 'there';

  return Response(body: 'Hi $name');
}
```

We can make a request to the above handler with no query parameters and we should see:

```
curl --request GET --url http://localhost:8080

Hi there
```

We can make a another request to the above handler with `?name=Dash` and we should see:

```
curl --request GET --url http://localhost:8080?name=Dash

Hi Dash
```

### Body

We can access the body of the incoming request via `context.request.body`.

```dart
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  // Access the incoming request.
  final request = context.request;

  // Access the request body as a `String`.
  final body = await request.body();

  return Response(body: 'The body is "$body".');
}
```

:::caution
The request body can only be read once.
:::

We can make a request to the above handler with some data and we should see:

```
curl --request POST \
  --url http://localhost:8080 \
  --header 'Content-Type: text/plain' \
  --data 'Hello!'

The body is "Hello!".
```

#### JSON

When the `Content-Type` is `application/json`, you can use `context.request.json()` to read the contents of the request body as a `Map<String, dynamic>`.

```dart
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  // Access the incoming request.
  final request = context.request;

  // Access the request body as parsed `JSON`.
  final body = await request.json();

  return Response.json(body: {'request_body': body});
}
```

We can make a request to the above handler with some data and we should see:

```
curl --request POST \
  --url http://localhost:8080/example \
  --header 'Content-Type: application/json' \
  --data '{
  "hello": "world"
}'

{
  "request_body": {
    "hello": "world"
  }
}
```

#### Form Data

When the `Content-Type` is `application/x-www-form-urlencoded` or `multipart/form-data`, you can use `context.request.formData()` to read the contents of the request body as `FormData`.

```dart
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  // Access the incoming request.
  final request = context.request;

  // Access the request body form data.
  final formData = await request.formData();

  return Response.json(body: {'form_data': formData.fields});
}
```

```
curl --request POST \
  --url http://localhost:8080/example \
  --data hello=world

{
  "form_data": {
    "hello": "world"
  }
}
```

If the request is a multipart form data request you can also access files that were uploaded.

```dart
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  // Access the incoming request.
  final request = context.request;

  // Access the request body form data.
  final formData = await request.formData();

  // Retrieve an uploaded file.
  final photo = formData.files['photo'];

  if (photo == null || photo.contentType.mimeType != contentTypePng.mimeType) {
    return Response(statusCode: HttpStatus.badRequest);
  }

  return Response.json(
    body: {'message': 'Successfully uploaded ${photo.name}'},
  );
}
```

```
curl --request POST \
  --url http://localhost:8080/example \
  --form photo=@photo.png

{
  "message": "Successfully uploaded photo.png"
}
```

:::info
The `formData` API is available since `dart_frog >=0.3.1` and the support for multipart form data was added in `dart_frog >=0.3.4`.
:::

:::caution
`request.formData()` will throw a `StateError` if the MIME type is not `application/x-www-form-urlencoded` or `multipart/form-data`.
:::

## Responses 📤

All route handlers must return an outbound response. In this section, we'll take a look at various ways in which we can create a custom response.

### Status Code

We can customize the status code of the response via the `statusCode` parameter on the `Response` object:

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(statusCode: 204);
}
```

### Headers

We can customize the headers of the response via the `headers` parameter on the `Response` object:

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(headers: {'hello': 'world'});
}
```

### Body

We've seen examples of returning a custom body via the default `Response` constructor:

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(body: 'Hello World');
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

Dart Frog supports dynamic routes. For example, if you create a file called `routes/posts/[id].dart`, then it will be accessible at `/posts/1`, `/posts/2`, and so on.

Routing parameters are forwarded to the `onRequest` method as seen below.

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context, String id) {
  return Response(body: 'post id: $id');
}
```

Dart Frog also supports nested dynamic routes. For example, if you create a file called, `routes/users/[userId]/posts/[postId].dart`, then it will be accessible at `/users/alice/posts/1`, `/users/sam/posts/42`, and so on.

Just as with all dynamic routes, routing parameters are forwarded to the `onRequest` method:

```dart
Response onRequest(RequestContext context, String userId, String postId) {
  return Response(body: 'user id: $userId, post id: $postId');
}
```

## Wildcard Routes ♾

Dart Frog supports wildcard routes. For example, if you create a file called `routes/posts/[...page].dart`, then it will be accessible at any path that starts with `/posts/`, with any number of levels, allowing it to called from `/posts/today`, `/posts/features/starred`, and so forth.

Routing parameters are forwarded to the `onRequest` method as seen below:

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context, String page) {
  return Response(body: 'post page: $page');
}
```

:::caution
Wildcard routes **must** be unique leaf routes on their route node, meaning that they need to be a file, and they need to be the only route in their folder.
:::

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
