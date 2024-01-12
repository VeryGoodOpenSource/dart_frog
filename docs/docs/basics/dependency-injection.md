---
sidebar_position: 3
title: 💉 Dependency Injection
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

We can later access the provided value from within a route handler using `context.read<T>()`:

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

### Order matters

In a real life application you will find yourself adding multiple `providers` to your project.

Some `providers` **will depend** on others, as with any application relying on dependency injection.

Let's take the example of a `Car` that depends on a `Wheel`.

We will have two `providers` where the second one depends on the first one for it to work:

1. A first `provider`, called `wheelMiddlewareProvider`, that creates the `Wheel` object

```dart
final _wheel = Wheel();

/// Provides a [Wheel] instance.
Middleware wheelMiddlewareProvider() {
  return provider<Wheel>(
    (_) => _wheel,
  );
}
```

2. A second `provider`, called `carMiddlewareProvider`, that provides a `Car` object

```dart
class Car {
  final Wheel wheel;

  Car({
    required this.wheel;
  });
}

/// Middleware to create the Car object
Middleware carMiddlewareProvider() {
  return provider<Car>(
    (context) => Car(
      wheel: context.read<Wheel>(),
    ),
  );
}
```

At this point, it seems clear that `carMiddlewareProvider` depends on `wheelMiddlewareProvider`.

When you try to access the instance of `Car` using `context.read<Car>()`, here is what will happen:

1. _Dart Frog_ will try to create the instance and return it. To do so, it will create a `Car` object and to fulfill its `wheel` parameter
2. It will "look above" in the dependency graph for a provider of `Wheel`
3. It will find it with `wheelMiddlewareProvider`, and so on.

This is how dependency injections works, but let's clarify what "look above" means.

We have to tell Dart Frog how to build a `Wheel` **before** it builds a `Car`. We do that by defining the order of the providers.

:::tip
In Dart Frog, dependencies are resolved from **bottom** to **top**  
:::

So if provider `B` depends on provider `A`, you will have to declare them as followed:

```dart
Handler middleware(Handler handler) {
  return handler
      .use(B())
      .use(A())
}
```

In the example we gave at the beginning where `carMiddlewareProvider` depends on `wheelMiddlewareProvider` we know it will work when we provided them like so:

```dart
Handler middleware(Handler handler) {
  return handler
      .use(carMiddlewareProvider())
      .use(wheelMiddlewareProvider())
}
```

But if we change the order of the providers it will not work:

```dart
Handler middleware(Handler handler) {
  return handler
      // This won't work because Dart Frog is bottom top
      .use(wheelMiddlewareProvider())
      .use(carMiddlewareProvider())
}
```

:::note
Right now, there is an issue about this [fix: Improve dependency injection order #745](https://github.com/VeryGoodOpenSource/dart_frog/issues/745) because some other DI frameworks are working top to bottom and dart_frog is bottom to top.

So you might want to keep that in mind for future releases, but as it would be a breaking change, the release version will reflect this.
:::
