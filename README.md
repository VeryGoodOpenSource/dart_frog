[![Dart Frog Logo][logo_white]][dart_frog_link_dark]
[![Dart Frog Logo][logo_black]][dart_frog_link_light]

Developed with 💙 by [Very Good Ventures][very_good_ventures_link] 🦄

[![ci][ci_badge]][ci_link]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

A fast, minimalistic backend framework for Dart.

## Quick Start 🚀

### Prerequisites 📝

In order to use Dart Frog you must have the [Dart SDK][dart_installation_link] installed on your machine.

### Installing 🧑‍💻

```sh
# 📦 Install the dart_frog cli from source
dart pub global activate dart_frog_cli
```

### Creating a Project ✨

Use the `dart_frog create` command to create a new project.

```sh
# 🚀 Create a new project called "my_project"
dart_frog create my_project
```

### Start the Dev Server 🏁

Next, open the newly created project and start the dev server via:

```sh
# 🏁 Start the dev server
dart_frog dev
```

### Create a Production Build 📦

Create a production build which includes a `DockerFile` so that you can deploy anywhere:

```sh
# 📦 Create a production build
dart_frog build
```

## Documentation 📝

### Routes 🚏

In Dart Frog, a route consists of an `onRequest` function (called a route handler) exported from a `.dart` file in the `routes` directory. Each endpoint is associated with a routes file based on its file name. Files named, `index.dart` will correspond to a `/` endpoint.

For example, if you create `routes/hello.dart` that exports an `onRequest` method like below, it will be accessible at `/hello`.

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(body: 'Hello World');
}
```

All route handlers have access to a `RequestContext` which can be used to access the incoming request as well as dependencies provided to the request context (see middleware).

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  // Access the incoming request.
  final request = context.request;

  // Return a response.
  return Response(body: 'Hello World');
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

#### Dynamic Routes 🌓

Dart Frog supports dynamic routes. For example, if you create a file called `routes/posts/<id>.dart`, then it will be accessible at `/posts/1`, `/posts/2`, etc.

Routing parameters are forwarded to the `onRequest` method as seen below.

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context, String id) {
  return Response(body: 'post id: $id');
}
```

### Middleware 🍔

Middleware in Dart Frog allows you to execute code before and after a request is processed. You can modify the inbound request and outbound responses, provide dependencies, and more!

In Dart Frog, a piece of middleware consists of a `middleware` function exported from a `_middleware.dart` file within a subdirectory of the `routes` folder. There can only ever be once piece of middleware per route directory with `routes/_middleware.dart` being middleware that is executed for all inbound requests.

```dart
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return (context) async {
    // Execute code before request is handled.

    // Forward the request to the respective handler.
    final response = await handler(context);

    // Execute code after request is handled.

    // Return a response.
    return response;
  };
}
```

We can chain built-in middleware, such as the `requestLogger` middleware via the `use` API. For example, if we create `routes/_middleware.dart` with the following contents, we will automatically log all requests to our server.

```dart
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler.use(requestLogger());
}
```

#### Dependency Injection 💉

Middleware can also be used to provide dependencies to a `RequestContext` via a `provider`.

`provider` is a type of middleware that can create and provide an instance of type `T` to the request context. The `create` callback is called lazily and the injected `RequestContext` can be used to perform additional lookups to access values provided upstream.

In the following example, we'll use a `provider` to inject a `String` into our request context.

```dart
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(provider<String>((context) => 'Welcome to Dart Frog!'));
}
```

We can later access the provided via from within a route handler using `context.read<T>()`:

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final greeting = context.read<String>();
  return Response(body: greeting);
}
```

### Testing 🧪

In Dart Frog, we can unit test our route handlers and middleware effectively because they are just pure functions.

For example, we can test our route handler above using `package:test`:

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
      const greeting = 'Hello World!';
      final context = _MockRequestContext();
      when(() => context.read<String>()).thenReturn(greeting);
      final response = route.onRequest(context);
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body(), completion(equals(greeting)));
    });
  });
}
```

In the above test, we're using `package:mocktail` to create a mock `RequestContext` and stub the return value when calling `context.read<String>()`. Then, all we need to do is call `onRequest` with the mocked context and we can assert that the response is what we expect. In this case, we're checking the statusCode and response body to ensure that the response is a 200 with the provided greeting.

For more information, see the [example][example_link] and our [roadmap][roadmap_link].

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

🚧 Generated Dart Client Package 📦

🚧 Generated API Documentation 📔

[dart_installation_link]: https://dart.dev/get-dart
[ci_badge]: https://github.com/VeryGoodOpenSource/dart_frog/actions/workflows/dart_frog.yaml/badge.svg
[ci_link]: https://github.com/VeryGoodOpenSource/dart_frog/actions/workflows/dart_frog.yaml
[dart_frog_link_dark]: https://github.com/verygoodopensource/dart_frog#gh-dark-mode-only
[dart_frog_link_light]: https://github.com/verygoodopensource/dart_frog#gh-light-mode-only
[example_link]: https://github.com/VeryGoodOpenSource/dart_frog/tree/main/example
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: ./assets/dart_frog_logo_black.png#gh-light-mode-only
[logo_white]: ./assets/dart_frog_logo_white.png#gh-dark-mode-only
[roadmap_link]: https://github.com/VeryGoodOpenSource/dart_frog/blob/main/ROADMAP.md
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_ventures_link]: https://verygood.ventures
