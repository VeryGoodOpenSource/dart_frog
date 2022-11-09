---
sidebar_position: 3
---

# Dependency Injection 💉

Middleware can be used to inject dependencies into a `RequestContext` via a `provider`.

## Provider

`provider` is a type of middleware that can create and provide an instance of type `T` to the request context. The `create` callback is called lazily and the injected `RequestContext` can be used to perform additional lookups to access values provided upstream.

### Basics

In the following example, we'll use a `provider` to inject a `String` into our request context.

```dart
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler.use(provider<String>((context) => 'Welcome to Dart Frog!'));
}
```

We can later access the provided `String` from within a route handler using `context.read<T>()`:

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final greeting = context.read<String>();
  return Response(body: greeting);
}
```

### Extracting Providers

In the above example, we defined the `provider` inline. This is fine for simple cases, but for more complex providers or providers which you want to reuse, it can be helpful to extract the provider to its own file:

```dart
Middleware greetingProvider() {
  return provider<String>((context) => 'Hello World');
}
```

Then, we can import and use the provider in one or more middleware:

```dart
Handler middleware(Handler handler) {
  return handler.use(greetingProvider());
}
```

### Providing Asynchronous Values

A `provider` can also be used to inject asynchronous values -- we just need to change the generic type to a `Future`:

```dart
Middleware asyncGreetingProvider() {
  return provider<Future<String>>((context) async => 'Hello World');
}
```

We can then use the provider in one or more middleware just as before:

```dart
Handler middleware(Handler handler) {
  return handler.use(asyncGreetingProvider());
}
```

Later, we can read the async value from a route handler via `context.read`:

```dart
Future<Response> onRequest(RequestContext context) async {
  final value = await context.read<Future<String>>();
  return Response(body: value);
}
```

:::note
When accessing a `Future` via `context.read` be sure to specify the `Future` as the generic type and `await` the result.
:::

:::tip
You can create a custom extension if you prefer:

```dart
extension ReadAsync on RequestContext {
  Future<T> readAsync<T extends Object>() => read<Future<T>>();
}
```

With the above extension, you can access the provided `Future` like:

```dart
Future<Response> onRequest(RequestContext context) async {
  final value = await context.readAsync<String>();
  return Response(body: value);
}
```

:::

### Lazy Initialization

By default, `provider` creates the provided value only when it is accessed. For example, given the following middleware:

```dart
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler.use(
    provider<String>((context) {
      // This code will never execute if `context.read<String>()` isn't called.
      print('create!');
      return 'Welcome to Dart Frog!';
    }),
  );
}
```

If we have a route handler that never invokes `context.read<String>()`, our value will never be created, and `create!` will never be logged:

```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) => Response();
```

### Caching

By default, a provided value will be created when it is accessed. This means that each time you read a value via `context.read`, the associated `create` method will be invoked.

As a result, you may wish to cache a provided value so that it isn't unnecessarily recreated on each read. We can do this quite easily by defining a provide value which we use to reference the provided value once it is created.

```dart
String? _greeting;

Middleware cachedGreetingProvider() {
  return provider<String>((context) => _greeting ??= 'Hello World');
}
```

:::note
The cached `_greeting` is private so that it can only be accessed within the context of this provider.
:::

This pattern can also be applied to async providers:

```dart
String? _greeting;

Middleware cachedAsyncGreetingProvider() {
  return provider<Future<String>>((context) async => _greeting ??= 'Hello World');
}
```

With the above implementations, the greeting will only be computed once and the cached value will be used for the duration of the application lifecycle.
