---
sidebar_position: 1
title: 👋 Hello World
description: Build a simple "Hello World" application.
---

# Hello World 👋

:::info
**Difficulty**: 🟢 Beginner<br/>
**Length**: 5 minutes

Before getting started, [read the prerequisites](/docs/overview#prerequisites) to make sure your development environment is ready.
:::

## Overview

In this tutorial, we're going to build an app that exposes a single endpoint and responds with a static response.

When we're done, we should be able to make a `GET` request to the `/` endpoint:

```bash
curl --request GET \
  --url http://localhost:8080
```

And our server should respond with the following response:

```
HTTP/1.1 200 OK
Connection: close
Content-Length: 21
Content-Type: text/plain; charset=utf-8


Welcome to Dart Frog!
```

## Creating a new app

To create a new Dart Frog app, open your terminal, `cd` into the directory where you'd like to create the app, and run the following command:

```bash
dart_frog create hello_world
```

You should see an output similar to:

```
✓ Creating hello_world (0.1s)
✓ Installing dependencies (1.7s)

Created hello_world at ./hello_world.

Get started by typing:

cd ./hello_world
dart_frog dev
```

:::tip
Install and use the [Dart Frog VS Code extension](https://marketplace.visualstudio.com/items?itemName=VeryGoodVentures.dart-frog) to easily create Dart Frog apps within your IDE.
:::

## Running the development server

You should now have a directory called `hello_world` -- `cd` into it:

```bash
cd hello_world
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

🎉 Congrats, you've created a `hello_world` application using Dart Frog. View the [full source code](https://github.com/VeryGoodOpenSource/dart_frog/tree/main/examples/hello_world).
