---
sidebar_position: 7
title: 🌱 Environments
---

# Environments 🌱

There are many ways that environments can be configured in a Dart Frog application. The
easiest way is to use environment variables via the Dart SDK.

As seen in the [dependency injection docs](dependency-injection.md), middleware can be used to provide dependencies to an application.

Following this approach, the snippet shows how a database client can be configured with different environments.

```dart
Handler middleware(Handler handler) {
  return handler
      .use(provider<CardsRepository>((_) {
        return DatabaseClient(
          dbUrl: Platform.environment['DB_URL'],
          dbUser: Platform.environment['DB_USER'],
          dbPassword: Platform.environment['DB_PASSWORD'],
        );
      }),
    );
}
```

When running the server, these environment variables can be passed along directly to Dart Frog commands:

Development server:

```bash
DB_URL=... DB_USER=... DB_PASSWORD=... dart_frog dev
```

Production server:

```bash
DB_URL=... DB_USER=... DB_PASSWORD=... dart build/server.dart
```

These variables can also be exported in the current session:

```bash
EXPORT DB_URL=...
EXPORT DB_USER=...
EXPORT DB_PASSWORD=...
```

:::warning
Accessing variables through `String.fromEnvironment` in a Dart Frog application will not work.`String.fromEnvironment` is meant to accesses variables set by the Dart
compiler or runtime, which does not apply to a Dart Frog application. Instead, use
`Platform.environment`.
:::
