---
sidebar_position: 1
title: Overview
---

# Overview 🎯

Dart Frog is built on top of [shelf](https://pub.dev/packages/shelf) and [mason](https://pub.dev/packages/mason) and is inspired by many tools including [remix.run](https://remix.run), [next.js](https://nextjs.org), and [express.js](https://expressjs.com).

The goal of Dart Frog is to help developers effectively build backends in Dart. Currently, Dart Frog is focused on optimizing the process of building backends which aggregate, compose, and normalize data from multiple sources.

Dart Frog provides a simple core with a small API surface area in order to reduce the learning curve and ramp-up time for developers. In addition, Dart Frog is intended to help Flutter/Dart developers maximize their productivity by having a unified tech stack that enables sharing tooling, models, and more!

## Quick Start 🚀

### Prerequisites 📝

In order to use Dart Frog you must have the [Dart SDK][dart_installation_link] installed on your machine.

:::info
Dart Frog requires Dart `">=2.19.0 <3.0.0"`
:::

### Installing 🧑‍💻

```shell
# 📦 Install the dart_frog cli from pub.dev
dart pub global activate dart_frog_cli
```

### Creating a Project ✨

Use the `dart_frog create` command to create a new project.

```shell
# 🚀 Create a new project called "my_project"
dart_frog create my_project
```

### Start the Dev Server 🏁

Next, open the newly created project and start the dev server via:

```shell
# 🏁 Start the dev server
dart_frog dev
```

:::tip
By default port `8080` is used. A custom port can be used via the `--port` option.
:::

:::tip
It's also possible to set a custom port for the dart vm service using `--dart-vm-port` option.

This is required when trying to run `dart_frog dev` multiple times.
:::

:::caution
Each release of the `dart_frog_cli` supports a specific version range of the `dart_frog` runtime. If the current version of the `dart_frog` runtime is incompatible with the installed `dart_frog_cli` version, an error will be reported and you will need to update your `dart_frog_cli` version or `dart_frog` version accordingly.
:::

### Create a Production Build 📦

Create a production build which includes a `DockerFile` so that you can deploy anywhere:

```shell
# 📦 Create a production build
dart_frog build
```

## Feature Set ✨

✅ Hot Reload ⚡️

✅ Dart Dev Tools ⚙️

✅ File System Routing 🚏

✅ Index Routes 🗂

✅ Nested Routes 🪆

✅ Dynamic Routes 🌓

✅ Middleware 🍔

✅ Dependency Injection 💉

✅ Production Builds 👷‍♂️

✅ Docker 🐳

✅ Static File Support 📁

✅ WebSocket Support 🔌

🚧 Generated Dart Client Package 📦

🚧 Generated API Documentation 📔

[dart_installation_link]: https://dart.dev/get-dart
