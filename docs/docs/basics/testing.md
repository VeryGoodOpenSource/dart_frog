---
sidebar_position: 5
title: 🧪 Testing
---

# Testing 🧪

In Dart Frog, we can effectively unit test our route handlers and middleware using [`package:test`](https://pub.dev/packages/test) and [`package:mocktail`](https://pub.dev/packages/mocktail).

## Route Handlers 🚏

Testing route handlers is pretty straightforward and doesn't require any new concepts because a route handler is just a plain Dart function.

### Basics

Let's take a look at how we can test the following route handler:

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(body: 'Hello World');
}
```

In the above handler, we're simply returning a `200` response with `'Hello World'` in the response body.

To test this, we can import our route handler, create a mock `RequestContext` using `package:mocktail`, and invoke `onRequest` with the mock request context to get a `Response`. Then, we can assert that the response is what we expect. In this case, we're checking the `statusCode` and response `body` to ensure that the response is a `200` and the body equals `'Hello World'`.

```dart
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/index.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('GET /', () {
    test('responds with a 200 and greeting.', () async {
      // Arrange
      final context = _MockRequestContext();

      // Act
      final response = route.onRequest(context);

      // Assert
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body(), completion(equals('Hello World')));
    });
  });
}
```

### Stubbing `context.read<T>`

Often times, your route handler won't be as simple. For example, it may resolve dependencies via the `RequestContext` like:

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final greeting = context.read<String>();
  return Response(body: greeting);
}
```

The steps to test the above route handler are the same as before. The only thing we need to add is a stub for `context.read`:

```dart
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/index.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('GET /', () {
    test('responds with a 200 and greeting.', () async {
      // Arrange
      final greeting = 'Hello!';
      final context = _MockRequestContext();
      when(() => context.read<String>()).thenReturn(greeting);

      // Act
      final response = route.onRequest(context);

      // Assert
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body(), completion(equals(greeting)));
    });
  });
}
```

## Middleware 🍔

Unit testing middleware is very similar to unit testing route handlers — they are both just dart functions after all!

### Basics

Let's take a look at a piece of middleware that provides a greeting to the `RequestContext` via the `provider` API:

```dart
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler.use(provider<String>((_) => 'Hello World'));
}
```

We can unit test this piece of middleware in isolation using `package:test` and `package:mocktail` just like before.

To test this, we need to import our middleware, create a mock `RequestContext` using `package:mocktail`, apply our middleware to a dummy handler, and invoke the handler with a mock request context. Then, we can assert that the simple handler we applied the middleware to had access to the provided value.

```dart
import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/_middleware.dart';

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('middleware', () {
    test('provides greeting', () async {
      // Arrange
      String? greeting;
      final handler = middleware(
        (context) {
          greeting = context.read<String>();
          return Response(body: '');
        },
      );
      final request = Request.get(Uri.parse('http://localhost/'));
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(request);

      // Act
      await handler(context);

      // Assert
      expect(greeting, equals('Hello World'));
    });
  });
}
```

:::info
We are stubbing the `context.request` with a real `Request` object so that the `provider` is able to inject the value.
:::
