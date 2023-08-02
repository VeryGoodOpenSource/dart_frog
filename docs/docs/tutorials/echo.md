---
sidebar_position: 2
title: 🔊 Echo
description: Build a simple "Echo" application.
---

# Echo 🔊

:::info
**Difficulty**: 🟢 Beginner<br/>
**Length**: 15 minutes

Before getting started, [read the prerequisites](/docs/overview#prerequisites) to make sure your development environment is ready.
:::

## Overview

In this tutorial, we're going to build an app that exposes a single endpoint and responds with a dynamic response which echoes the path back.

When we're done, we should be able to make a `GET` request to the `/<message>` endpoint with any `message`:

```bash
# <message> is "ping"
curl --request GET \
  --url http://localhost:8080/ping

# <message> is "pong"
curl --request GET \
  --url http://localhost:8080/pong
```

And our server should respond with the following responses:

```
HTTP/1.1 200 OK
Connection: close
Content-Length: 21
Content-Type: text/plain; charset=utf-8


ping

---

HTTP/1.1 200 OK
Connection: close
Content-Length: 21
Content-Type: text/plain; charset=utf-8


pong
```

## Creating a new app

To create a new Dart Frog app, open your terminal, `cd` into the directory where you'd like to create the app, and run the following command:

```bash
dart_frog create echo
```

You should see an output similar to:

```
✓ Creating echo (0.1s)
✓ Installing dependencies (1.7s)

Created echo at ./echo.

Get started by typing:

cd ./echo
dart_frog dev
```

:::tip
Install and use the [Dart Frog VS Code extension](https://marketplace.visualstudio.com/items?itemName=VeryGoodVentures.dart-frog) to easily create Dart Frog apps within your IDE.
:::

## Running the development server

You should now have a directory called `echo` -- `cd` into it:

```bash
cd echo
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

## Creating a dynamic route

Now that we have a running application, let's start by deleting the root route since we won't need it for this example:

```bash
rm routes/index.dart
```

Next, let's create `routes/[message].dart`:

```bash
touch routes/[message].dart
```

:::note
The square brackets `[...]` indicates that the path segment is dynamic and will match anything. Learn more about [dynamic routes](/docs/basics/routes#dynamic-routes-).
:::

Finally, let's define an `onRequest` method in the newly created route:

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context, String message) {
  return Response(body: message);
}
```

:::note
Since this route handler corresponds to a dynamic route, we will received the parameter as an argument in `onRequest`.
:::

:::tip
Install and use the [Dart Frog VS Code extension](https://marketplace.visualstudio.com/items?itemName=VeryGoodVentures.dart-frog) to easily create new dynamic routes within your IDE.
:::

Save the changes and hot reload should kick in ⚡️

```bash
[hotreload] - Application reloaded.
```

Make sure it's working by opening [http://localhost:8080/ping](http://localhost:8080/ping) in your browser or via `cURL`:

```bash
curl --request GET \
  --url http://localhost:8080/ping
```

If everything succeeded, you should see your message echoed back -- in this case, we should see `ping`.

Let's try making a different request by visiting [http://localhost:8080/pong](http://localhost:8080/pong) in your browser or via `cURL`:

```bash
curl --request GET \
  --url http://localhost:8080/pong
```

This time you should see `pong`.

🎉 Congrats, you've created an `echo` application using Dart Frog. View the [full source code](https://github.com/VeryGoodOpenSource/dart_frog/tree/main/examples/echo).
