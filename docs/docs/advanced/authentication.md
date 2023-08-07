---
sidebar_position: 7
title: 🔒 Authentication
---

# Authentication 🔑

There are many different approaches, protocols, and services when tackling authentication in a backend, which can all be affected by the business logic of the application.

Because of this Dart Frog does not bundle any feature, helpers or resources for authentication out of the box. This means that developers have full freedom to implement server authentication in the best way that fits their needs.

Nevertheless, there are a few common patterns that can used in many different approaches to give the developer a head start. For example, there is a package called [`dart_frog_auth`](https://pub.dev/packages/dart_frog_auth), which makes it easy for a simple authentication method to be implemented while also
layering the foundation for more advanced authentication. See below for more details:

## Dart Frog Auth

The authentication methods provided in `dart_frog_auth` are based on `Authorization` specification,
as defined in [`General HTTP`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication). Here you will find support
for `Basic` and `Bearer` authentications, which are common authentication methods used by many developers.

## Basic Authentication

Like its name infers, this is a basic authentication scheme that consists of the client sending
a user's credentials in the `Authorization` header. The credentials should be concatenated by a
colon and encoded in a base64 string. The encoded credentials are then set in the header as
follows:

```
Authorization: Basic TOKEN
```

Due to the credentials being sent encoded and not encrypted, this authentication can be considered
less secure, especially when used without HTTPS/TLS.

## Bearer Authentication

Similar to the basic authentication scheme, the bearer authentication scheme sends a user's credentials to the header with a single token instead of a username and password.

The bearer token format is up to the issuing authority server to define. It commonly
consists of an access token with encrypted information that the server can validate.

The header is defined as follows:

```
Authorization: Bearer TOKEN
```

## Usage

Both authentication schemes described above can be applied in a Dart Frog server by adding middleware to the routes that needs to be secured.

Consider the following application:

```
lib/
  |- user_repository.dart
routes/
  |- admin/
  |    |- index.dart
  |- posts/
       |- index.dart
```

Routes under `posts` are public, so they don't require any kind of authentication, while on
`admin`, only authenticated users can access their endpoints. It's worth noting that the
`user_repository.dart` file under the `lib` folder offers methods to authenticate users.

### Basic Method

To implement the basic authentication scheme on `admin` routes, a middleware file should
be created under the admin folder with the following content:

```dart
// routes/admin/_middleware.dart
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:blog/user.dart';

Handler middleware(Handler handler) {
  final userRepository = ...;
  return handler
      .use(requestLogger())
      .use(
        basicAuthentication<User>(
          userFromCredentials: userRepository.fetchFromCredentials,
        ),
      );
}
```

The `userFromCredentials` parameter must be a method that receives two positional arguments (username
and password) and returns a user if any is found for those credentials, otherwise it should return null.

If a user is returned (authenticated), it will be set in the request context and can be read by request handlers, for example:

```dart
import 'package:dart_frog/dart_frog.dart';
import 'package:blog/user.dart';

Response onRequest(RequestContext context) {
  final user = context.read<User>();
  return Response.json(body: {'user': user.id});
}
```

In the case of `null` being returned (unauthenticated), the middleware will automatically send an unauthorized `401` in the response.

### Bearer Method

To implement the bearer authentication scheme on `admin` routes, the same logic used for the
basic method can be applied:

```dart
// routes/admin/_middleware.dart
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:blog/user.dart';

Handler middleware(Handler handler) {
  final userRepository = ...;
  return handler
      .use(requestLogger())
      .use(
        bearerTokenAuthentication<User>(
          userFromToken: userRepository.fetchFromAccessToken,
        ),
      );
}
```

The `userFromToken` parameter must be a function that receives one positional argument (the
token sent on the authorization header) and returns a user if any is found for that token.

Again, just like in the basic method, if a user is returned, it will be set in the request
context and can be read on request handlers, for example:

```dart
import 'package:dart_frog/dart_frog.dart';
import 'package:blog/user.dart';

Response onRequest(RequestContext context) {
  final user = context.read<User>();
  return Response.json(body: {'user': user.id});
}
```

In the case of `null` being returned (unauthenticated), the middleware will automatically send an unauthorized `401` in the response.

### Filtering Routes

In many instances, developers will want to apply authentication to some routes, while not to others.

One of those can be described by looking at implementing a basic RESTful CRUD API. In order to make
such an API that allows consumers to create, update, delete, and get user information, the following list
of routes will need to be created:

- `POST /users`: Creates a user
- `PATCH /users/[id]`: Updates the user with the given id.
- `DELETE /users/[id]`: Deletes the user with the given id.
- `GET /users/[id]`: Returns the user with the given id.

Those endpoints can be translated to the following structure in a Dart Frog backend:

```
routes/
  |- users/
      |- index.dart // Handles the POST
      |- [id].dart // Handles PATCH, DELETE and GET
      |- _middleware.dart
```

It would make sense for the `PATCH`, `DELETE`, and `GET` routes to be authenticated ones, since
only an authenticated user would be allowed to change this information.

To accomplish that, we need the middleware to apply authentication to all routes except `POST`.

Such behavior is possible with the use of the `applies` optional predicate:

```dart
Handler middleware(Handler handler) {
  final userRepository = UserRepository();

  return handler
      .use(requestLogger())
      .use(provider<UserRepository>((_) => userRepository))
      .use(
        basicAuthentication<User>(
          userFromCredentials: userFromCredentials(userRepository),
          applies: (RequestContext context) async =>
              context.request.method != HttpMethod.post,
        ),
      );
}
```

In the above example, only routes that are not `POST` will have authentication checked.

### Authentication vs. Authorization

Both Authentication and authorization are related, but are different concepts that are often confused.

Authentication is about WHO the user is, while authorization is about WHAT a user can do.

These concepts are related since we need to know who the user is in order to check if they can
perform or not a given operation.

`dart_frog_auth` only solves the authentication part of the problem. To enforce
authorization, it is up to the developer to implement it manually, or use an authorization issue
system like OAuth2, for example.

In technical terms, a request should return `401` (Unauthorized) when authentication fails and
`403` (Forbidden) when authorization failed.

The following snippet shows how authorization can be manually checked in `DELETE /users/[id]` route,
where only the current logged user is allowed to delete itself:

```dart
Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.delete => _deleteUser(context, id),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _deleteUser(RequestContext context, String id) async {
  // If there is no authenticated user, `dart_frog_auth` automatically
  // responds with a 401.

  final user = context.read<User>();
  if (user.id != id) {
    // If the current authenticated user, obtained via `context.read<User>` is
    // not the same of the one of the incoming request, a forbidden is returned!
    return Response(statusCode: HttpStatus.forbidden);
  }
  await context.read<UserRepository>().deleteUser(user.id);
  return Response(statusCode: HttpStatus.noContent);
}
```
