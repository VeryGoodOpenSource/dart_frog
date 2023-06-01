---
sidebar_position: 7
title: 🌱 Environments
---

# Environments 🌱

---

The ability of configuring different environments is necessary for any real world applications.

The application needs to be able be configured to run a development environment, or a staging one
and ultimately, a production one.

There are many ways that different environments can be achieved in a Dart Frog application, the
out of the box one is by making the use of environment variables, which is a feature provided
directly from the Dart SDK.

As seen in the Dependency injection example, middleware can be used to provide dependencies
to the application.

Following that approach, the snippet bellow can be used to exemplify how a database client that
can be is configured through different environments can be provided to the application.

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

Then, when running the server, those variables can be passed along directly on the Dart Frog
commands, like:

For development server:

```bash
DB_URL=... DB_USER=... DB_PASSWORD=... dart_frog server
```

For production server

```bash
DB_URL=... DB_USER=... DB_PASSWORD=... dart build/server.dart
```

For convenience, these variables can also be exported in the current session.

:::warning
Commonly used in Flutter applications, accessing variables through `String.fromEnvironment` in
a Dart frog application will not work, that method is meant to accesses variables set by the dart
compiler or runtime, which doesn't apply on a Dart frog application. Due that
`Platform.environment` should be used instead.
:::
