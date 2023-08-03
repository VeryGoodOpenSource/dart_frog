---
sidebar_position: 3
title: 🔢 Counter
description: Build a simple "Counter" application.
---

# Counter 🔢

:::info
**Difficulty**: 🟢 Beginner<br/>
**Length**: 15 minutes

Before getting started, [read the prerequisites](/docs/overview#prerequisites) to make sure your development environment is ready.
:::

## Overview

In this tutorial, we're going to build an app that exposes a single endpoint and responds with the number of times the route was requested.

When we're done, we should be able to make multiple `GET` requests to the `/` endpoint:

```bash
# 1st time
curl --request GET \
  --url http://localhost:8080

# 2nd time
curl --request GET \
  --url http://localhost:8080
```

And our server should respond with the following responses:

```
HTTP/1.1 200 OK
Connection: close
Content-Length: 21
Content-Type: text/plain; charset=utf-8


You have requested this route 1 time(s).

---

HTTP/1.1 200 OK
Connection: close
Content-Length: 21
Content-Type: text/plain; charset=utf-8


You have requested this route 2 time(s).
```

## Creating a new app

To create a new Dart Frog app, open your terminal, `cd` into the directory where you'd like to create the app, and run the following command:

```bash
dart_frog create counter
```

You should see an output similar to:

```
✓ Creating counter (0.1s)
✓ Installing dependencies (1.7s)

Created counter at ./counter.

Get started by typing:

cd ./counter
dart_frog dev
```

:::tip
Install and use the [Dart Frog VS Code extension](https://marketplace.visualstudio.com/items?itemName=VeryGoodVentures.dart-frog) to easily create Dart Frog apps within your IDE.
:::

## Running the development server

You should now have a directory called `counter` -- `cd` into it:

```bash
cd counter
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

## Updating the root route

Now that we have a running application, let's start by updating the root route at `routes/index.dart`:

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  const count = 1;
  return Response(
    body: 'You have requested this route $count time(s).',
  );
}
```

Save the changes and hot reload should kick in ⚡️

```bash
[hotreload] - Application reloaded.
```

Now if we visit [http://localhost:8080](http://localhost:8080) in the browser or via `cURL`:

```bash
curl --request GET \
  --url http://localhost:8080
```

We should see our new response:

```
You have requested this route 1 time(s).
```

Awesome! There's just one small issue...

Make another request and note that the count does not increment. This is expected because we hard-coded the count in our route handler. Let's fix that by introducing some middleware!

## Creating middleware

In Dart Frog, middleware allows you to execute code before and/or after a request is processed. In this example, we're going to create a piece of middleware that provides a count to our routes.

:::note
A piece of middleware can modify the inbound request and outbound responses, provide dependencies, and more! [Learn more about middleware](/docs/basics/middleware).
:::

For this example, we're going to create a single global piece of middleware but a Dart Frog application can consist of multiple pieces of middleware which are scoped to nested routes.

To create a global piece of middleware, we just need to create a file called `_middleware.dart` in the `routes` directory and define a `middleware` method:

```dart
import 'package:dart_frog/dart_frog.dart';

// This piece of middleware does nothing at the moment.
Handler middleware(Handler handler) {
  return handler;
}
```

:::tip
Install and use the [Dart Frog VS Code extension](https://marketplace.visualstudio.com/items?itemName=VeryGoodVentures.dart-frog) to easily create new middleware within your IDE.
:::

Now that we've defined the middleware, we can create our private `count` and provide the count to all sub routes:

```dart
import 'package:dart_frog/dart_frog.dart';

int _count = 0;

Handler middleware(Handler handler) {
  return handler.use(provider<int>((_) => ++_count));
}
```

:::tip
The `use` method on a `Handler` allows you to chain multiple `middleware`.
:::

In the above snippet, we are automatically incrementing the `_count` whenever the value is read.

The last thing we need to do is update our route handler to use the provided count.

Open `routes/index.dart` and replace the hard-coded count with the provided value using `context.read`:

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final count = context.read<int>();
  return Response(
    body: 'You have requested this route $count time(s).',
  );
}
```

:::note
`context.read<T>()` allows a route to access an instance of type `T` which was provided via `middleware`.
:::

Be sure to save all the changes and hot reload should kick in ⚡️

```bash
[hotreload] - Application reloaded.
```

Now if we visit [http://localhost:8080](http://localhost:8080) in the browser or via `cURL`:

```bash
curl --request GET \
  --url http://localhost:8080
```

We should see our response:

```
You have requested this route 1 time(s).
```

Now if we reload the page or make another request, the count should update:

```
You have requested this route 2 time(s).
```

:::note
If you restart the server, the count will be reset to 0 because it is only maintained in memory.
:::

🎉 Congrats, you've created a `counter` application using Dart Frog. View the [full source code](https://github.com/VeryGoodOpenSource/dart_frog/tree/main/examples/counter).
