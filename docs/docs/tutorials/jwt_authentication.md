---
sidebar_position: 6
title: 🪪  Authentication with JWT
description: Build an authenticated dart frog service.
---

# Authentication with JWT 🪪

:::info
**Difficulty**: 🟠 Intermediate<br/>
**Length**: 30 minutes

Before getting started, [read the Dart Frog prerequisites](/docs/overview#prerequisites) to make sure your development environment is ready.
:::

## Overview

In this tutorial, we're going to build an app that exposes endpoints accessible only to users
that have been authenticated.

When we're done, we should be able to authenticate with a user credentials, and access the
protected routes.

Like mentioned in the [Dart Frog Authentication documentation](https://dartfrog.vgv.dev/docs/advanced/authentication),
there are many ways of implementing authentication in a backend, for this tutorial we will use a
hardcoded, in memory, database of users and [Json Web Tokens](https://jwt.io/) (or for short JWTs)
for the user's authentication token.

## Creating a new app

To create a new Dart Frog app, open your terminal, change to the directory where you'd like to create the app, and run the following command:

```bash
dart_frog create authenticated_app
```

You should see an output similar to:

```
✓ Creating authenticated_app (0.1s)
✓ Installing dependencies (1.7s)

Created authenticated_app at ./authenticated_app.

Get started by typing:

cd ./authenticated_app
dart_frog dev
```

:::tip
Install and use the [Dart Frog VS Code extension](https://marketplace.visualstudio.com/items?itemName=VeryGoodVentures.dart-frog) to easily create Dart Frog apps within your IDE.
:::

## Running the development server

You should now have a directory called `authenticated_app`. Let's change directories into the newly created project:

```bash
cd authenticated_app
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

## The hardcode domain code

To keep the tutorial simple and focused on authentication, our database of users will be hardcoded and
the `User` model will be simple, containing just an id and a name.

For next steps, use the code below to create the domain classes.

```dart
// lib/user.dart
class User {
  const User({
    required this.id,
    required this.name,
    required this.password,
  });

  final String id;
  final String name;
  final String password;
}
import 'package:authenticated_app/user.dart';
```

```dart
// lib/authenticator.dart
class Authenticator {
  static const _users = {
    'john': User(
      id: '1',
      name: 'John',
      password: '123',
    ),
    'jack': User(
      id: '2',
      name: 'Jack',
      password: '321',
    ),
  };

  static const _passwords = {
    // ⚠️ Never store user's password in plain text, these values are in plain text
    // just for the sake of the tutorial.
    'john': '123',
    'jack': '321',
  };

  User? findByUsernameAndPassword({
    required String username,
    required String password,
  }) {
    final user = _users[username];

    if (user != null && _passwords[username] == password) {
      return user;
    }

    return null;
  }
}

```

We also need to provide our `Authenticator` to our routes. Since it will be used by
several routes like a sign in and all the routes that are authenticated, it makes sense to
provide it to all routes.

In order to do so, we can use [Dart frog's dependency injection](https://dartfrog.vgv.dev/docs/basics/dependency-injection)
and create a middleware in the root of our `routes` folder with the following code:

```dart
import 'package:authenticated_app/authenticator.dart';
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler.use(
    provider<Authenticator>(
      (_) => Authenticator(),
    ),
  );
}
```

## Writing a Sign In route

Now that we have all the domain code necessary to authenticate users given an username and a password.

So let's now create a route which we can use to authenticate users. In the routes folder, create the file below:

```dart
// routes/sign_in.dart
import 'dart:io';

import 'package:authenticated_app/authenticator.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _onPost(context),
    _ => Future.value(
        Response(statusCode: HttpStatus.methodNotAllowed),
      ),
  };
}

Future<Response> _onPost(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final username = body['username'] as String?;
  final password = body['password'] as String?;

  if (username == null || password == null) {
    return Response(statusCode: HttpStatus.badRequest);
  }

  final authenticator = context.read<Authenticator>();

  final user = authenticator.findByUsernameAndPassword(
    username: username,
    password: password,
  );

  if (user == null) {
    return Response(statusCode: HttpStatus.unauthorized);
  } else {
    return Response.json(
      body: { 'token': username },
    );
  }
}
```

To people familiar with Dart Frog, the code above should be no real challenge, we are simply handling the
request in the following steps:

- Check if we have all the info needed, returning `badRequest` otherwise.
- Get our `Authenticator` dependency from our dependency injection.
- User the authenticator to get a user that match the request's credential.
- Returns `unauthorized` (401) if there is no user, or returns the user username as the authentication token otherwise.

But wait, you could be thinking that using the user username as an authentication token is quite unsafe.
And for sure it is, but for now, let's just for the sake of simplicity, for now lets go with that
in order to finish our authentication setup before introducing more complex security methods.

Try now running a `curl` in the terminal to get a token:

```bash
curl -X POST \
     -H "Content-Type: application/json" \
     -d '{"username": "john", "password": "123"}'  \
     http://localhost:8080/sign_in

# {"token":"john"}
```

## Requiring authentication to access routes

Now that we have the means to get an authentication token, we can now protect routes to require a token
to be provided in
order to access them.

To start lets create the following route:

```dart
// routes/tasks/index.dart
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) {
  return switch (context.request.method) {
    HttpMethod.post => _onPost(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onPost(RequestContext context) async {
  final task = await context.request.body();
  return Response.json(
    body: {
      'recorded_task': task,
    },
  );
}
```

This route doesn't do much for now, it just reads the request and answers with a body with the
received task name. Also it isn't yet protected.

To protect our route, we will use [`dart_frog_auth`](https://pub.dev/packages/dart_frog_auth), a
package provided by Dart Frog that makes it easier to implement token based authentications.

So lets start by adding it to the project:

```bash
dart pub add dart_frog_auth
```

First, we need to create a method in our authenticator class which will be responsible to validate
an authentication token, since right now, our authentication token is just the user's username,
we can add the following snippet to the `Authenticator` class:

```dart
  User? verifyToken(String username) {
    return _users[username];
  }
```

If the token is valid, the user will be returned, otherwise, the method will return `null`.

Next, lets create the following middleware under `routes/tasks`:

```dart
import 'package:authenticated_app/authenticator.dart';
import 'package:authenticated_app/user.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';

Handler middleware(Handler handler) {
  return handler.use(
    bearerAuthentication<User>(
      authenticator: (context, token) async {
        final authenticator = context.read<Authenticator>();
        return authenticator.verifyToken(token);
      },
    ),
  );
}
```

What this middleware does, is to add a Bearer token authentication checking to all requests incoming
into the routes of that namespace.

The usage of `bearerAuthentication` middleware, which is provided by `dart_frog_auth` is quite simple.
We simply need to inform the a function to the `bearerAuthentication` attribute, this function receives
the current `RequestContext` and the token that was passed in the request.

If the token is valid and belongs to a user, the function must return that user. Otherwise,
it should return null.

This middleware will automatically return `unauthorized` response to incoming requests when
no valid tokens are provided, so if we go ahead and try the following command in our terminal:

```bash
# Note the additional `-v`, so we can see the status code in the output
curl -d "Buy bread" \
     -v \
     http://localhost:8080/tasks
```

We should see the following line in the output

```bash
< HTTP/1.1 401 Unauthorized
```

But if we inform a valid and correct authentication token:

```bash
curl -d "Buy bread" \
     -v \
     -H "Authorization: Bearer john" \
     http://localhost:8080/tasks
```

The correct response of that route should be output:

```bash
{"recorded_task":"Buy bread"}
```

Additionally, the `bearerAuthentication` middleware will set the returned user in the request context,
so any route handlers affected by it, will have access to the user that is currently authenticated.

With that information, we can change our tasks routes to have a more interesting response:

```dart
import 'dart:io';

import 'package:authenticated_app/user.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) {
  return switch (context.request.method) {
    HttpMethod.post => _onPost(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onPost(RequestContext context) async {
  final task = await context.request.body();
  final user = context.read<User>();

  return Response.json(
    body: {
      'recorded_task': task,
      'user_id': user.id,
    },
  );
}
```

## Protecting the authentication token

This is a good point to review what we have done so far:

- We have created a sign in route, where credentials can be posted, and an authentication token
  is returned if valid.
- We have routes that can only be accessed if an authentication token is sent in the request.

But like we noticed in the steps before, our authentication token is quite unsafe, it is nothing
more than the user's username, meaning that if an ill intentioned person guesses another user's
username, which is not something hard to do, they could pass as that user and maybe steal
information or other bad actions.

To avoid that, we have to make our tokens in a way where they cannot be faked, guessed or tampered.
There are many ways of doing that, in this tutorial, we will use JWT, a widely used standard in the
industry to secure issued tokens. This tutorial will not go much in deep on how JWT tokens work
under the hood, so to get a better understanding on how they work, be sure to check their official
[documentation](https://jwt.io/).

Right, with that brief introduction, lets get that done. Luckily, the Dart ecosystem already have
a handy package that makes it easy to work with JWT tokens, lets start by adding that dependency to our
project:

```dart
dart pub add dart_jsonwebtoken
```

Next, lets add the following method to our `Authenticator` class:

```dart
  String generateToken({
    required String username,
    required User user,
  }) {
    final jwt = JWT(
      {
        'id': user.id,
        'name': user.name,
        'username': username,
      },
    );

    return jwt.sign(SecretKey('123'));
  }
```

That will take care of generating a JWT token. Note that we call a method `sign` out of the token,
passing a secret key, as the name implies, this key is secret and should be kept as such, in this
tutorial we are keeping it hard coded for the sake of simplicity, but in a real case application,
be sure to correctly store it and pass it to the code in a way where then will remain secret to outsiders.

The sign method will create a signature out of the data we passed to it, that signature will be part
of the token and will later on allow us to check if an authentication token that we've received
is valid and if hasn't been tampered!

Alright, now we need to make a small change in our sign in route, as it should not return the username
anymore, but rather the token created by this method instead. The route will now look like this:

```dart
import 'dart:io';

import 'package:authenticated_app/authenticator.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _onPost(context),
    _ => Future.value(
        Response(statusCode: HttpStatus.methodNotAllowed),
      ),
  };
}

Future<Response> _onPost(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final username = body['username'] as String?;
  final password = body['password'] as String?;

  if (username == null || password == null) {
    return Response(statusCode: HttpStatus.badRequest);
  }

  final authenticator = context.read<Authenticator>();

  final user = authenticator.findByUsernameAndPassword(
    username: username,
    password: password,
  );

  if (user == null) {
    return Response(statusCode: HttpStatus.unauthorized);
  } else {
    return Response.json(
      body: {
        'token': authenticator.generateToken(
          username: username,
          user: user,
        ),
      },
    );
  }
}
```

Finally, we now need to change the `Authenticator` to verify the signed token instead of just
checking if there is a user with the username.

```dart
  User? verifyToken(String token) {
    try {
      final payload = JWT.verify(
        token,
        SecretKey('123'),
      );

      final payloadData = payload.payload as Map<String, dynamic>;

      final username = payloadData['username'] as String;
      return _users[username];
    } catch (e) {
      return null;
    }
  }
```

And that is it, with the addition of a signed token if someone tamper the information stored in it,
or try to forge a token without knowing the secret key, the authentication will fail and only real,
authenticated users will be able to access protected routes!

🎉 Congrats, you've created an application using Dart Frog with authentication.
