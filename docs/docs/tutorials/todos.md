---
sidebar_position: 4
title: 🗒 Todos
description: Build a simple "Todos" application.
---

# Todos 🗒

:::info
**Difficulty**: 🟠 Intermediate<br/>
**Length**: 30 minutes

Before getting started, [read the prerequisites](/docs/overview#prerequisites) to make sure your development environment is ready.
:::

## Overview

In this tutorial, we're going to build an app that exposes two endpoints which allow us to perform `CRUD` operations on a list of todos.

:::note
`CRUD` stands for `create`, `read`, `update`, and `delete`.
:::

When we're done, we should have an app that supports the following requests:

```bash
# Create a new todo
curl --request POST \
  --url http://localhost:8080/todos \
  --header 'Content-Type: application/json' \
  --data '{
  "title": "Take out trash"
}'

# Read all todos
curl --request GET \
  --url http://localhost:8080/todos

# Read a specific todo by id
curl --request GET \
  --url http://localhost:8080/todos/<id>

# Update a specific todo by id
curl --request PUT \
  --url http://localhost:8080/todos/<id> \
  --header 'Content-Type: application/json' \
  --data '{
  "title": "Take out trash!",
  "isCompleted": true
}'

# Delete a specific todo by id
curl --request DELETE \
  --url http://localhost:8080/todos/<id>
```

## Creating a new app

To create a new Dart Frog app, open your terminal, `cd` into the directory where you'd like to create the app, and run the following command:

```bash
dart_frog create todos
```

You should see an output similar to:

```
✓ Creating todos (0.1s)
✓ Installing dependencies (1.7s)

Created todos at ./todos.

Get started by typing:

cd ./todos
dart_frog dev
```

:::tip
Install and use the [Dart Frog VS Code extension](https://marketplace.visualstudio.com/items?itemName=VeryGoodVentures.dart-frog) to easily create Dart Frog apps within your IDE.
:::

## Running the development server

You should now have a directory called `todos` -- `cd` into it:

```bash
cd todos
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

## Todos Data Source

### Creating `package:todos_data_source`

Now that we have a running application, we need to define an abstraction for a todos data source which will be responsible for exposing APIs to perform C.R.U.D operations on a list of todos.

Since the todos data source is not tightly coupled to our Dart Frog application, we can create it as a package.

:::tip
Decomposing a project into one or more packages is a form of modularization which can help with maintainability and reusability.
:::

In this tutorial, we're going to use [package:mason_cli](https://pub.dev/packages/mason_cli) to help us create new packages quickly.

:::info
If you don't have `package:mason_cli` installed, follow the [installation directions](https://pub.dev/packages/mason_cli#installation) before proceeding.
:::

Install the latest version of the [Very Good Dart Package](https://brickhub.dev/bricks/very_good_dart_package) by running:

```bash
mason add -g very_good_dart_package
```

Then we can create the `todos_data_source` via:

```bash
mason make very_good_dart_package --project_name "todos_data_source" --description "A generic interface for managing todos." -o packages
```

:::info
Alternatively you can run `mason make very_good_dart_package` and fill out the interactive prompts.
:::

Now we should have the scaffolding for the `todos_data_source` package under `packages/todos_data_source`:

```
├── packages
│   └── todos_data_source
│       ├── README.md
│       ├── analysis_options.yaml
│       ├── coverage_badge.svg
│       ├── lib
│       ├── pubspec.lock
│       ├── pubspec.yaml
│       └── test
```

### Updating the `pubspec.yaml`

Next, let's update the `pubspec.yaml` in the `todos_data_source` to include the relevant dependencies:

```yaml
name: todos_data_source
description: A generic interface for managing todos.
version: 0.1.0+1
publish_to: none

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  equatable: ^2.0.3
  json_annotation: ^4.6.0
  meta: ^1.7.0

dev_dependencies:
  build_runner: ^2.2.0
  json_serializable: ^6.3.1
  mocktail: ^1.0.0
  test: ^1.19.2
  very_good_analysis: ^5.0.0
```

Install the newly added dependencies via:

```bash
dart pub get
```

:::caution
Make sure to run the above command from within the `packages/todos_data_source` directory.
:::

### Creating the `Todo` model

Next, let's define our todo model which will be a plain Dart class which represents a single todo item.

Create `lib/src/models/todo.dart` with the following contents:

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'todo.g.dart';

/// {@template todo}
/// A single todo item.
///
/// Contains a [title], [description] and [id], in addition to a [isCompleted]
/// flag.
///
/// If an [id] is provided, it cannot be empty. If no [id] is provided, one
/// will be generated.
///
/// [Todo]s are immutable and can be copied using [copyWith], in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Todo extends Equatable {
  /// {@macro todo}
  Todo({
    this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
  }) : assert(id == null || id.isNotEmpty, 'id cannot be empty');

  /// The unique identifier of the todo.
  ///
  /// Cannot be empty.
  final String? id;

  /// The title of the todo.
  ///
  /// Note that the title may be empty.
  final String title;

  /// The description of the todo.
  ///
  /// Defaults to an empty string.
  final String description;

  /// Whether the todo is completed.
  ///
  /// Defaults to `false`.
  final bool isCompleted;

  /// Returns a copy of this todo with the given values updated.
  ///
  /// {@macro todo}
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Deserializes the given `Map<String, dynamic>` into a [Todo].
  static Todo fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  /// Converts this [Todo] into a `Map<String, dynamic>`.
  Map<String, dynamic> toJson() => _$TodoToJson(this);

  @override
  List<Object?> get props => [id, title, description, isCompleted];
}
```

:::info
The `Todo` class uses [package:json_serializable](https://pub.dev/packages/json_serializable) to handle generating the code to (de)serialize to and from JSON.

The `Todo` class extends uses [package:equatable](https://pub.dev/packages/equatable) to override `==` and `hashCode` so that we can compare `Todo` instances by value.
:::

Next, we need to use [package:build_runner](https://pub.dev/packages/build_runner) to generate the relevant code for `json_serializable`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

We should see that the `todos.g.dart` file was generated and our code should not have any errors or warnings at this point.

Let's add a barrel file to export our `models` by creating `lib/src/models/models.dart` and exporting `todos.dart`:

```dart
export 'todo.dart';
```

Also, let's update the library exports to include the `models` in `lib/todos_data_source.dart`:

```dart
/// A generic interface for managing todos.
library todos_data_source;

export 'src/models/models.dart';
export 'src/todos_data_source.dart';
```

That's it for the `models`. Next, we'll define the `TodosDataSource` class.

### Creating the `TodosDataSource`

The last thing we need to do in the `todos_data_source` package is define the `TodosDataSource` class. It's going to be an `abstract` class because it will serve as an interface which can have multiple concrete implementations.

Create `lib/src/todos_data_source.dart` with the following contents:

```dart
import 'package:todos_data_source/todos_data_source.dart';

/// An interface for a todos data source.
/// A todos data source supports basic C.R.U.D operations.
/// * C - Create
/// * R - Read
/// * U - Update
/// * D - Delete
abstract class TodosDataSource {
  /// Create and return the newly created todo.
  Future<Todo> create(Todo todo);

  /// Return all todos.
  Future<List<Todo>> readAll();

  /// Return a todo with the provided [id] if one exists.
  Future<Todo?> read(String id);

  /// Update the todo with the provided [id] to match [todo] and
  /// return the updated todo.
  Future<Todo> update(String id, Todo todo);

  /// Delete the todo with the provided [id] if one exists.
  Future<void> delete(String id);
}
```

We're done with the `todos_data_source`! Next, we'll create a concrete implementation of the `TodosDataSource` interface which is backed by an in-memory cache.

## In-Memory Todos Data Source

Just like with the `todos_data_source`, we'll create a new package called `in_memory_todos_data_source` to contain the concrete implementation.

### Creating `package:in_memory_todos_data_source`

From the root of the project we can use `mason make` to generate a new Dart package again:

```bash
mason make very_good_dart_package --project_name "in_memory_todos_data_source" --description "An in-memory implementation of the TodosDataSource interface." -o packages
```

### Updating the `pubspec.yaml`

Next, let's update the `pubspec.yaml` in the `in_memory_todos_data_source` to include the relevant dependencies:

```yaml
name: in_memory_todos_data_source
description: An in-memory implementation of the TodosDataSource interface.
version: 0.1.0+1
publish_to: none

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  todos_data_source:
    path: ../todos_data_source
  uuid: ^3.0.6

dev_dependencies:
  mocktail: ^1.0.0
  test: ^1.19.2
  very_good_analysis: ^5.0.0
```

:::note
The `in_memory_todos_data_source` depends on the `todos_data_source` via `path`.
:::

Install the newly added dependencies via:

```bash
dart pub get
```

### Creating the `InMemoryTodosDataSource`

Next, let's update `lib/src/in_memory_todos_data_source.dart` to implement the `TodosDataSource` interface:

```dart
import 'package:todos_data_source/todos_data_source.dart';
import 'package:uuid/uuid.dart';

/// An in-memory implementation of the [TodosDataSource] interface.
class InMemoryTodosDataSource implements TodosDataSource {
  /// Map of ID -> Todo
  final _cache = <String, Todo>{};

  @override
  Future<Todo> create(Todo todo) async {
    final id = const Uuid().v4();
    final createdTodo = todo.copyWith(id: id);
    _cache[id] = createdTodo;
    return createdTodo;
  }

  @override
  Future<List<Todo>> readAll() async => _cache.values.toList();

  @override
  Future<Todo?> read(String id) async => _cache[id];

  @override
  Future<Todo> update(String id, Todo todo) async {
    return _cache.update(id, (value) => todo);
  }

  @override
  Future<void> delete(String id) async => _cache.remove(id);
}
```

That's it! We're done making the data sources for our Dart Frog application and we're ready to start working on the Dart Frog app itself!

:::tip
You can create your own `TodosDataSource` implementation that is backed by databases like [mysql](https://pub.dev/packages/mysql1), [postgres](https://pub.dev/packages/postgres), or [redis](https://pub.dev/packages/redis).
:::

## Updating the `pubspec.yaml`

The first thing we need to do is update the root `pubspec.yaml` to contain the `todos_data_source` and `in_memory_todos_data_source` dependencies:

```yaml
name: todos
description: An example todos app built with Dart Frog.
version: 1.0.0+1
publish_to: none

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  dart_frog: ^1.0.0
  in_memory_todos_data_source:
    path: packages/in_memory_todos_data_source
  todos_data_source:
    path: packages/todos_data_source

dev_dependencies:
  http: ^1.0.0
  mocktail: ^1.0.0
  test: ^1.19.2
  very_good_analysis: ^5.0.0
```

Install the newly added dependencies via:

```bash
dart pub get
```

## Creating middleware

Next, let's create a top-level piece of `middleware` to provide the `TodosDataSource` to all routes. Create `routes/_middleware.dart` with the following contents:

```dart
import 'package:dart_frog/dart_frog.dart';
import 'package:in_memory_todos_data_source/in_memory_todos_data_source.dart';

final _dataSource = InMemoryTodosDataSource();

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(provider<TodosDataSource>((_) => _dataSource));
}
```

:::info
We're providing a single instance of the `TodosDataSource` so we have a single source of data for the lifetime of the application.

In addition, we're using the `requestLogger` middleware from `package:dart_frog` to log all requests for debugging.
:::

:::tip
Install and use the [Dart Frog VS Code extension](https://marketplace.visualstudio.com/items?itemName=VeryGoodVentures.dart-frog) to easily create new middleware within your IDE.
:::

## Creating the `/todos` route

Next, delete the root route handler at `routes/index.dart` and create a route handler for the `/todos` endpoint by creating `routes/todos/index.dart`:

```dart
import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:todos_data_source/todos_data_source.dart';

FutureOr<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context);
    case HttpMethod.post:
      return _post(context);
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
    case HttpMethod.put:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(RequestContext context) async {
  final dataSource = context.read<TodosDataSource>();
  final todos = await dataSource.readAll();
  return Response.json(body: todos);
}

Future<Response> _post(RequestContext context) async {
  final dataSource = context.read<TodosDataSource>();
  final todo = Todo.fromJson(
    await context.request.json() as Map<String, dynamic>,
  );

  return Response.json(
    statusCode: HttpStatus.created,
    body: await dataSource.create(todo),
  );
}
```

:::tip
Install and use the [Dart Frog VS Code extension](https://marketplace.visualstudio.com/items?itemName=VeryGoodVentures.dart-frog) to easily create new routes within your IDE.
:::

:::note
We're using `context.read<TodosDataSource>` to access the provided instance of the `TodosDataSource`.
:::

In this route handler, we only want to handle `GET` and `POST` requests so we're using a `switch` statement on `context.request.method`. If the `HttpMethod` is not `GET` or `POST`, our route handler responds with a `405` status code (method not allowed).

In addition, we're using the `Response.json` constructor to respond with `Content-Type: application/json`.

Next, we'll create a route handler for the `/todos/<id>` endpoint so that we can handle operations for a specific todo.

## Creating the `/todos/<id>` route

We can create a dynamic route to handle matching and `id` by creating a file called: `routes/todos/[id].dart`.

:::info
Dynamic routes allow you to have one or more dynamic path segments in your route. Learn more about [dynamic routes](/docs/basics/routes#dynamic-routes-).
:::

```dart
import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:todos_data_source/todos_data_source.dart';

FutureOr<Response> onRequest(RequestContext context, String id) async {
  final dataSource = context.read<TodosDataSource>();
  final todo = await dataSource.read(id);

  if (todo == null) {
    return Response(statusCode: HttpStatus.notFound, body: 'Not found');
  }

  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context, todo);
    case HttpMethod.put:
      return _put(context, id, todo);
    case HttpMethod.delete:
      return _delete(context, id);
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
    case HttpMethod.post:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(RequestContext context, Todo todo) async {
  return Response.json(body: todo);
}

Future<Response> _put(RequestContext context, String id, Todo todo) async {
  final dataSource = context.read<TodosDataSource>();
  final updatedTodo = Todo.fromJson(
    await context.request.json() as Map<String, dynamic>,
  );
  final newTodo = await dataSource.update(
    id,
    todo.copyWith(
      title: updatedTodo.title,
      description: updatedTodo.description,
      isCompleted: updatedTodo.isCompleted,
    ),
  );

  return Response.json(body: newTodo);
}

Future<Response> _delete(RequestContext context, String id) async {
  final dataSource = context.read<TodosDataSource>();
  await dataSource.delete(id);
  return Response(statusCode: HttpStatus.noContent);
}
```

:::note
`onRequest` now has two parameters: `RequestContext`, and `id`. The `id` path segment is forwarded to the `onRequest` method call.
:::

Just like in the `/todos` route handler, we are switching on the `context.request.method` and selectively handling `GET`, `PUT`, and `DELETE` requests.

## Summary

Be sure to save all the changes and hot reload should kick in ⚡️

```bash
[hotreload] - Application reloaded.
```

You should now be able to make requests to create, read, update, and delete todos:

```bash
# Create a new todo
curl --request POST \
  --url http://localhost:8080/todos \
  --header 'Content-Type: application/json' \
  --data '{
  "title": "Take out trash"
}'

# Read all todos
curl --request GET \
  --url http://localhost:8080/todos

# Read a specific todo by id
curl --request GET \
  --url http://localhost:8080/todos/<id>

# Update a specific todo by id
curl --request PUT \
  --url http://localhost:8080/todos/<id> \
  --header 'Content-Type: application/json' \
  --data '{
  "title": "Take out trash!",
  "isCompleted": true
}'

# Delete a specific todo by id
curl --request DELETE \
  --url http://localhost:8080/todos/<id>
```

:::note
You should see detailed request logs in the console due to the `requestLogger` middleware that look similar to:

```bash
2022-08-09T17:43:35.816387  0:00:00.016484 GET     [200] /todos
2022-08-09T17:44:05.561021  0:00:00.022465 POST    [201] /todos
```

:::

🎉 Congrats, you've created a `todos` application using Dart Frog. View the [full source code](https://github.com/VeryGoodOpenSource/dart_frog/tree/main/examples/todos).
