"use strict";(self.webpackChunkdart_frog_docs=self.webpackChunkdart_frog_docs||[]).push([[695],{4022:(e,n,t)=>{t.r(n),t.d(n,{assets:()=>i,contentTitle:()=>r,default:()=>h,frontMatter:()=>s,metadata:()=>o,toc:()=>c});const o=JSON.parse('{"id":"tutorials/todos","title":"\ud83d\uddd2 Todos","description":"Build a simple \\"Todos\\" application.","source":"@site/docs/tutorials/todos.md","sourceDirName":"tutorials","slug":"/tutorials/todos","permalink":"/docs/tutorials/todos","draft":false,"unlisted":false,"editUrl":"https://github.com/VeryGoodOpenSource/dart_frog/tree/main/docs/docs/tutorials/todos.md","tags":[],"version":"current","sidebarPosition":4,"frontMatter":{"sidebar_position":4,"title":"\ud83d\uddd2 Todos","description":"Build a simple \\"Todos\\" application."},"sidebar":"docs","previous":{"title":"\ud83d\udd22 Counter","permalink":"/docs/tutorials/counter"},"next":{"title":"\ud83d\udd0c WebSocket Counter","permalink":"/docs/tutorials/web_socket_counter"}}');var d=t(4848),a=t(8453);const s={sidebar_position:4,title:"\ud83d\uddd2 Todos",description:'Build a simple "Todos" application.'},r="Todos \ud83d\uddd2",i={},c=[{value:"Overview",id:"overview",level:2},{value:"Creating a new app",id:"creating-a-new-app",level:2},{value:"Running the development server",id:"running-the-development-server",level:2},{value:"Todos Data Source",id:"todos-data-source",level:2},{value:"Creating <code>package:todos_data_source</code>",id:"creating-packagetodos_data_source",level:3},{value:"Updating the <code>pubspec.yaml</code>",id:"updating-the-pubspecyaml",level:3},{value:"Creating the <code>Todo</code> model",id:"creating-the-todo-model",level:3},{value:"Creating the <code>TodosDataSource</code>",id:"creating-the-todosdatasource",level:3},{value:"In-Memory Todos Data Source",id:"in-memory-todos-data-source",level:2},{value:"Creating <code>package:in_memory_todos_data_source</code>",id:"creating-packagein_memory_todos_data_source",level:3},{value:"Updating the <code>pubspec.yaml</code>",id:"updating-the-pubspecyaml-1",level:3},{value:"Creating the <code>InMemoryTodosDataSource</code>",id:"creating-the-inmemorytodosdatasource",level:3},{value:"Updating the <code>pubspec.yaml</code>",id:"updating-the-pubspecyaml-2",level:2},{value:"Creating middleware",id:"creating-middleware",level:2},{value:"Creating the <code>/todos</code> route",id:"creating-the-todos-route",level:2},{value:"Creating the <code>/todos/&lt;id&gt;</code> route",id:"creating-the-todosid-route",level:2},{value:"Summary",id:"summary",level:2}];function l(e){const n={a:"a",admonition:"admonition",code:"code",h1:"h1",h2:"h2",h3:"h3",header:"header",p:"p",pre:"pre",strong:"strong",...(0,a.R)(),...e.components};return(0,d.jsxs)(d.Fragment,{children:[(0,d.jsx)(n.header,{children:(0,d.jsx)(n.h1,{id:"todos-",children:"Todos \ud83d\uddd2"})}),"\n",(0,d.jsxs)(n.admonition,{type:"info",children:[(0,d.jsxs)(n.p,{children:[(0,d.jsx)(n.strong,{children:"Difficulty"}),": \ud83d\udfe0 Intermediate",(0,d.jsx)("br",{}),"\n",(0,d.jsx)(n.strong,{children:"Length"}),": 30 minutes"]}),(0,d.jsxs)(n.p,{children:["Before getting started, ",(0,d.jsx)(n.a,{href:"/docs/overview#prerequisites",children:"read the prerequisites"})," to make sure your development environment is ready."]})]}),"\n",(0,d.jsx)(n.h2,{id:"overview",children:"Overview"}),"\n",(0,d.jsxs)(n.p,{children:["In this tutorial, we're going to build an app that exposes two endpoints which allow us to perform ",(0,d.jsx)(n.code,{children:"CRUD"})," operations on a list of todos."]}),"\n",(0,d.jsx)(n.admonition,{type:"note",children:(0,d.jsxs)(n.p,{children:[(0,d.jsx)(n.code,{children:"CRUD"})," stands for ",(0,d.jsx)(n.code,{children:"create"}),", ",(0,d.jsx)(n.code,{children:"read"}),", ",(0,d.jsx)(n.code,{children:"update"}),", and ",(0,d.jsx)(n.code,{children:"delete"}),"."]})}),"\n",(0,d.jsx)(n.p,{children:"When we're done, we should have an app that supports the following requests:"}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-bash",children:'# Create a new todo\ncurl --request POST \\\n  --url http://localhost:8080/todos \\\n  --header \'Content-Type: application/json\' \\\n  --data \'{\n  "title": "Take out trash"\n}\'\n\n# Read all todos\ncurl --request GET \\\n  --url http://localhost:8080/todos\n\n# Read a specific todo by id\ncurl --request GET \\\n  --url http://localhost:8080/todos/<id>\n\n# Update a specific todo by id\ncurl --request PUT \\\n  --url http://localhost:8080/todos/<id> \\\n  --header \'Content-Type: application/json\' \\\n  --data \'{\n  "title": "Take out trash!",\n  "isCompleted": true\n}\'\n\n# Delete a specific todo by id\ncurl --request DELETE \\\n  --url http://localhost:8080/todos/<id>\n'})}),"\n",(0,d.jsx)(n.h2,{id:"creating-a-new-app",children:"Creating a new app"}),"\n",(0,d.jsxs)(n.p,{children:["To create a new Dart Frog app, open your terminal, ",(0,d.jsx)(n.code,{children:"cd"})," into the directory where you'd like to create the app, and run the following command:"]}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-bash",children:"dart_frog create todos\n"})}),"\n",(0,d.jsx)(n.p,{children:"You should see an output similar to:"}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{children:"\u2713 Creating todos (0.1s)\n\u2713 Installing dependencies (1.7s)\n\nCreated todos at ./todos.\n\nGet started by typing:\n\ncd ./todos\ndart_frog dev\n"})}),"\n",(0,d.jsx)(n.admonition,{type:"tip",children:(0,d.jsxs)(n.p,{children:["Install and use the ",(0,d.jsx)(n.a,{href:"https://marketplace.visualstudio.com/items?itemName=VeryGoodVentures.dart-frog",children:"Dart Frog VS Code extension"})," to easily create Dart Frog apps within your IDE."]})}),"\n",(0,d.jsx)(n.h2,{id:"running-the-development-server",children:"Running the development server"}),"\n",(0,d.jsxs)(n.p,{children:["You should now have a directory called ",(0,d.jsx)(n.code,{children:"todos"})," -- ",(0,d.jsx)(n.code,{children:"cd"})," into it:"]}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-bash",children:"cd todos\n"})}),"\n",(0,d.jsx)(n.p,{children:"Then, run the following command:"}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-bash",children:"dart_frog dev\n"})}),"\n",(0,d.jsxs)(n.p,{children:["This will start the development server on port ",(0,d.jsx)(n.code,{children:"8080"}),":"]}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{children:"\u2713 Running on http://localhost:8080 (1.3s)\nThe Dart VM service is listening on http://127.0.0.1:8181/YKEF_nbwOpM=/\nThe Dart DevTools debugger and profiler is available at: http://127.0.0.1:8181/YKEF_nbwOpM=/devtools/#/?uri=ws%3A%2F%2F127.0.0.1%3A8181%2FYKEF_nbwOpM%3D%2Fws\n[hotreload] Hot reload is enabled.\n"})}),"\n",(0,d.jsxs)(n.p,{children:["Make sure it's working by opening ",(0,d.jsx)(n.a,{href:"http://localhost:8080",children:"http://localhost:8080"})," in your browser or via ",(0,d.jsx)(n.code,{children:"cURL"}),":"]}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-bash",children:"curl --request GET \\\n  --url http://localhost:8080\n"})}),"\n",(0,d.jsxs)(n.p,{children:["If everything succeeded, you should see ",(0,d.jsx)(n.code,{children:"Welcome to Dart Frog!"}),"."]}),"\n",(0,d.jsx)(n.h2,{id:"todos-data-source",children:"Todos Data Source"}),"\n",(0,d.jsxs)(n.h3,{id:"creating-packagetodos_data_source",children:["Creating ",(0,d.jsx)(n.code,{children:"package:todos_data_source"})]}),"\n",(0,d.jsx)(n.p,{children:"Now that we have a running application, we need to define an abstraction for a todos data source which will be responsible for exposing APIs to perform C.R.U.D operations on a list of todos."}),"\n",(0,d.jsx)(n.p,{children:"Since the todos data source is not tightly coupled to our Dart Frog application, we can create it as a package."}),"\n",(0,d.jsx)(n.admonition,{type:"tip",children:(0,d.jsx)(n.p,{children:"Decomposing a project into one or more packages is a form of modularization which can help with maintainability and reusability."})}),"\n",(0,d.jsxs)(n.p,{children:["In this tutorial, we're going to use ",(0,d.jsxs)(n.a,{href:"https://pub.dev/packages/mason_cli",children:["package",":mason_cli"]})," to help us create new packages quickly."]}),"\n",(0,d.jsx)(n.admonition,{type:"info",children:(0,d.jsxs)(n.p,{children:["If you don't have ",(0,d.jsx)(n.code,{children:"package:mason_cli"})," installed, follow the ",(0,d.jsx)(n.a,{href:"https://pub.dev/packages/mason_cli#installation",children:"installation directions"})," before proceeding."]})}),"\n",(0,d.jsxs)(n.p,{children:["Install the latest version of the ",(0,d.jsx)(n.a,{href:"https://brickhub.dev/bricks/very_good_dart_package",children:"Very Good Dart Package"})," by running:"]}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-bash",children:"mason add -g very_good_dart_package\n"})}),"\n",(0,d.jsxs)(n.p,{children:["Then we can create the ",(0,d.jsx)(n.code,{children:"todos_data_source"})," via:"]}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-bash",children:'mason make very_good_dart_package --project_name "todos_data_source" --description "A generic interface for managing todos." -o packages\n'})}),"\n",(0,d.jsx)(n.admonition,{type:"info",children:(0,d.jsxs)(n.p,{children:["Alternatively you can run ",(0,d.jsx)(n.code,{children:"mason make very_good_dart_package"})," and fill out the interactive prompts."]})}),"\n",(0,d.jsxs)(n.p,{children:["Now we should have the scaffolding for the ",(0,d.jsx)(n.code,{children:"todos_data_source"})," package under ",(0,d.jsx)(n.code,{children:"packages/todos_data_source"}),":"]}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{children:"\u251c\u2500\u2500 packages\n\u2502   \u2514\u2500\u2500 todos_data_source\n\u2502       \u251c\u2500\u2500 README.md\n\u2502       \u251c\u2500\u2500 analysis_options.yaml\n\u2502       \u251c\u2500\u2500 coverage_badge.svg\n\u2502       \u251c\u2500\u2500 lib\n\u2502       \u251c\u2500\u2500 pubspec.lock\n\u2502       \u251c\u2500\u2500 pubspec.yaml\n\u2502       \u2514\u2500\u2500 test\n"})}),"\n",(0,d.jsxs)(n.h3,{id:"updating-the-pubspecyaml",children:["Updating the ",(0,d.jsx)(n.code,{children:"pubspec.yaml"})]}),"\n",(0,d.jsxs)(n.p,{children:["Next, let's update the ",(0,d.jsx)(n.code,{children:"pubspec.yaml"})," in the ",(0,d.jsx)(n.code,{children:"todos_data_source"})," to include the relevant dependencies:"]}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-yaml",children:"name: todos_data_source\ndescription: A generic interface for managing todos.\nversion: 0.1.0+1\npublish_to: none\n\nenvironment:\n  sdk: '>=3.0.0 <4.0.0'\n\ndependencies:\n  equatable: ^2.0.3\n  json_annotation: ^4.6.0\n  meta: ^1.7.0\n\ndev_dependencies:\n  build_runner: ^2.2.0\n  json_serializable: ^6.3.1\n  mocktail: ^1.0.0\n  test: ^1.19.2\n  very_good_analysis: ^5.0.0\n"})}),"\n",(0,d.jsx)(n.p,{children:"Install the newly added dependencies via:"}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-bash",children:"dart pub get\n"})}),"\n",(0,d.jsx)(n.admonition,{type:"caution",children:(0,d.jsxs)(n.p,{children:["Make sure to run the above command from within the ",(0,d.jsx)(n.code,{children:"packages/todos_data_source"})," directory."]})}),"\n",(0,d.jsxs)(n.h3,{id:"creating-the-todo-model",children:["Creating the ",(0,d.jsx)(n.code,{children:"Todo"})," model"]}),"\n",(0,d.jsx)(n.p,{children:"Next, let's define our todo model which will be a plain Dart class which represents a single todo item."}),"\n",(0,d.jsxs)(n.p,{children:["Create ",(0,d.jsx)(n.code,{children:"lib/src/models/todo.dart"})," with the following contents:"]}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-dart",children:"import 'package:equatable/equatable.dart';\nimport 'package:json_annotation/json_annotation.dart';\nimport 'package:meta/meta.dart';\n\npart 'todo.g.dart';\n\n/// {@template todo}\n/// A single todo item.\n///\n/// Contains a [title], [description] and [id], in addition to a [isCompleted]\n/// flag.\n///\n/// If an [id] is provided, it cannot be empty. If no [id] is provided, one\n/// will be generated.\n///\n/// [Todo]s are immutable and can be copied using [copyWith], in addition to\n/// being serialized and deserialized using [toJson] and [fromJson]\n/// respectively.\n/// {@endtemplate}\n@immutable\n@JsonSerializable()\nclass Todo extends Equatable {\n  /// {@macro todo}\n  Todo({\n    this.id,\n    required this.title,\n    this.description = '',\n    this.isCompleted = false,\n  }) : assert(id == null || id.isNotEmpty, 'id cannot be empty');\n\n  /// The unique identifier of the todo.\n  ///\n  /// Cannot be empty.\n  final String? id;\n\n  /// The title of the todo.\n  ///\n  /// Note that the title may be empty.\n  final String title;\n\n  /// The description of the todo.\n  ///\n  /// Defaults to an empty string.\n  final String description;\n\n  /// Whether the todo is completed.\n  ///\n  /// Defaults to `false`.\n  final bool isCompleted;\n\n  /// Returns a copy of this todo with the given values updated.\n  ///\n  /// {@macro todo}\n  Todo copyWith({\n    String? id,\n    String? title,\n    String? description,\n    bool? isCompleted,\n  }) {\n    return Todo(\n      id: id ?? this.id,\n      title: title ?? this.title,\n      description: description ?? this.description,\n      isCompleted: isCompleted ?? this.isCompleted,\n    );\n  }\n\n  /// Deserializes the given `Map<String, dynamic>` into a [Todo].\n  static Todo fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);\n\n  /// Converts this [Todo] into a `Map<String, dynamic>`.\n  Map<String, dynamic> toJson() => _$TodoToJson(this);\n\n  @override\n  List<Object?> get props => [id, title, description, isCompleted];\n}\n"})}),"\n",(0,d.jsxs)(n.admonition,{type:"info",children:[(0,d.jsxs)(n.p,{children:["The ",(0,d.jsx)(n.code,{children:"Todo"})," class uses ",(0,d.jsxs)(n.a,{href:"https://pub.dev/packages/json_serializable",children:["package",":json_serializable"]})," to handle generating the code to (de)serialize to and from JSON."]}),(0,d.jsxs)(n.p,{children:["The ",(0,d.jsx)(n.code,{children:"Todo"})," class extends uses ",(0,d.jsxs)(n.a,{href:"https://pub.dev/packages/equatable",children:["package",":equatable"]})," to override ",(0,d.jsx)(n.code,{children:"=="})," and ",(0,d.jsx)(n.code,{children:"hashCode"})," so that we can compare ",(0,d.jsx)(n.code,{children:"Todo"})," instances by value."]})]}),"\n",(0,d.jsxs)(n.p,{children:["Next, we need to use ",(0,d.jsxs)(n.a,{href:"https://pub.dev/packages/build_runner",children:["package",":build_runner"]})," to generate the relevant code for ",(0,d.jsx)(n.code,{children:"json_serializable"}),":"]}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-bash",children:"dart run build_runner build --delete-conflicting-outputs\n"})}),"\n",(0,d.jsxs)(n.p,{children:["We should see that the ",(0,d.jsx)(n.code,{children:"todos.g.dart"})," file was generated and our code should not have any errors or warnings at this point."]}),"\n",(0,d.jsxs)(n.p,{children:["Let's add a barrel file to export our ",(0,d.jsx)(n.code,{children:"models"})," by creating ",(0,d.jsx)(n.code,{children:"lib/src/models/models.dart"})," and exporting ",(0,d.jsx)(n.code,{children:"todos.dart"}),":"]}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-dart",children:"export 'todo.dart';\n"})}),"\n",(0,d.jsxs)(n.p,{children:["Also, let's update the library exports to include the ",(0,d.jsx)(n.code,{children:"models"})," in ",(0,d.jsx)(n.code,{children:"lib/todos_data_source.dart"}),":"]}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-dart",children:"/// A generic interface for managing todos.\nlibrary todos_data_source;\n\nexport 'src/models/models.dart';\nexport 'src/todos_data_source.dart';\n"})}),"\n",(0,d.jsxs)(n.p,{children:["That's it for the ",(0,d.jsx)(n.code,{children:"models"}),". Next, we'll define the ",(0,d.jsx)(n.code,{children:"TodosDataSource"})," class."]}),"\n",(0,d.jsxs)(n.h3,{id:"creating-the-todosdatasource",children:["Creating the ",(0,d.jsx)(n.code,{children:"TodosDataSource"})]}),"\n",(0,d.jsxs)(n.p,{children:["The last thing we need to do in the ",(0,d.jsx)(n.code,{children:"todos_data_source"})," package is define the ",(0,d.jsx)(n.code,{children:"TodosDataSource"})," class. It's going to be an ",(0,d.jsx)(n.code,{children:"abstract"})," class because it will serve as an interface which can have multiple concrete implementations."]}),"\n",(0,d.jsxs)(n.p,{children:["Create ",(0,d.jsx)(n.code,{children:"lib/src/todos_data_source.dart"})," with the following contents:"]}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-dart",children:"import 'package:todos_data_source/todos_data_source.dart';\n\n/// An interface for a todos data source.\n/// A todos data source supports basic C.R.U.D operations.\n/// * C - Create\n/// * R - Read\n/// * U - Update\n/// * D - Delete\nabstract class TodosDataSource {\n  /// Create and return the newly created todo.\n  Future<Todo> create(Todo todo);\n\n  /// Return all todos.\n  Future<List<Todo>> readAll();\n\n  /// Return a todo with the provided [id] if one exists.\n  Future<Todo?> read(String id);\n\n  /// Update the todo with the provided [id] to match [todo] and\n  /// return the updated todo.\n  Future<Todo> update(String id, Todo todo);\n\n  /// Delete the todo with the provided [id] if one exists.\n  Future<void> delete(String id);\n}\n"})}),"\n",(0,d.jsxs)(n.p,{children:["We're done with the ",(0,d.jsx)(n.code,{children:"todos_data_source"}),"! Next, we'll create a concrete implementation of the ",(0,d.jsx)(n.code,{children:"TodosDataSource"})," interface which is backed by an in-memory cache."]}),"\n",(0,d.jsx)(n.h2,{id:"in-memory-todos-data-source",children:"In-Memory Todos Data Source"}),"\n",(0,d.jsxs)(n.p,{children:["Just like with the ",(0,d.jsx)(n.code,{children:"todos_data_source"}),", we'll create a new package called ",(0,d.jsx)(n.code,{children:"in_memory_todos_data_source"})," to contain the concrete implementation."]}),"\n",(0,d.jsxs)(n.h3,{id:"creating-packagein_memory_todos_data_source",children:["Creating ",(0,d.jsx)(n.code,{children:"package:in_memory_todos_data_source"})]}),"\n",(0,d.jsxs)(n.p,{children:["From the root of the project we can use ",(0,d.jsx)(n.code,{children:"mason make"})," to generate a new Dart package again:"]}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-bash",children:'mason make very_good_dart_package --project_name "in_memory_todos_data_source" --description "An in-memory implementation of the TodosDataSource interface." -o packages\n'})}),"\n",(0,d.jsxs)(n.h3,{id:"updating-the-pubspecyaml-1",children:["Updating the ",(0,d.jsx)(n.code,{children:"pubspec.yaml"})]}),"\n",(0,d.jsxs)(n.p,{children:["Next, let's update the ",(0,d.jsx)(n.code,{children:"pubspec.yaml"})," in the ",(0,d.jsx)(n.code,{children:"in_memory_todos_data_source"})," to include the relevant dependencies:"]}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-yaml",children:"name: in_memory_todos_data_source\ndescription: An in-memory implementation of the TodosDataSource interface.\nversion: 0.1.0+1\npublish_to: none\n\nenvironment:\n  sdk: '>=3.0.0 <4.0.0'\n\ndependencies:\n  todos_data_source:\n    path: ../todos_data_source\n  uuid: ^3.0.6\n\ndev_dependencies:\n  mocktail: ^1.0.0\n  test: ^1.19.2\n  very_good_analysis: ^5.0.0\n"})}),"\n",(0,d.jsx)(n.admonition,{type:"note",children:(0,d.jsxs)(n.p,{children:["The ",(0,d.jsx)(n.code,{children:"in_memory_todos_data_source"})," depends on the ",(0,d.jsx)(n.code,{children:"todos_data_source"})," via ",(0,d.jsx)(n.code,{children:"path"}),"."]})}),"\n",(0,d.jsx)(n.p,{children:"Install the newly added dependencies via:"}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-bash",children:"dart pub get\n"})}),"\n",(0,d.jsxs)(n.h3,{id:"creating-the-inmemorytodosdatasource",children:["Creating the ",(0,d.jsx)(n.code,{children:"InMemoryTodosDataSource"})]}),"\n",(0,d.jsxs)(n.p,{children:["Next, let's update ",(0,d.jsx)(n.code,{children:"lib/src/in_memory_todos_data_source.dart"})," to implement the ",(0,d.jsx)(n.code,{children:"TodosDataSource"})," interface:"]}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-dart",children:"import 'package:todos_data_source/todos_data_source.dart';\nimport 'package:uuid/uuid.dart';\n\n/// An in-memory implementation of the [TodosDataSource] interface.\nclass InMemoryTodosDataSource implements TodosDataSource {\n  /// Map of ID -> Todo\n  final _cache = <String, Todo>{};\n\n  @override\n  Future<Todo> create(Todo todo) async {\n    final id = const Uuid().v4();\n    final createdTodo = todo.copyWith(id: id);\n    _cache[id] = createdTodo;\n    return createdTodo;\n  }\n\n  @override\n  Future<List<Todo>> readAll() async => _cache.values.toList();\n\n  @override\n  Future<Todo?> read(String id) async => _cache[id];\n\n  @override\n  Future<Todo> update(String id, Todo todo) async {\n    return _cache.update(id, (value) => todo);\n  }\n\n  @override\n  Future<void> delete(String id) async => _cache.remove(id);\n}\n"})}),"\n",(0,d.jsx)(n.p,{children:"That's it! We're done making the data sources for our Dart Frog application and we're ready to start working on the Dart Frog app itself!"}),"\n",(0,d.jsx)(n.admonition,{type:"tip",children:(0,d.jsxs)(n.p,{children:["You can create your own ",(0,d.jsx)(n.code,{children:"TodosDataSource"})," implementation that is backed by databases like ",(0,d.jsx)(n.a,{href:"https://pub.dev/packages/mysql1",children:"mysql"}),", ",(0,d.jsx)(n.a,{href:"https://pub.dev/packages/postgres",children:"postgres"}),", or ",(0,d.jsx)(n.a,{href:"https://pub.dev/packages/redis",children:"redis"}),"."]})}),"\n",(0,d.jsxs)(n.h2,{id:"updating-the-pubspecyaml-2",children:["Updating the ",(0,d.jsx)(n.code,{children:"pubspec.yaml"})]}),"\n",(0,d.jsxs)(n.p,{children:["The first thing we need to do is update the root ",(0,d.jsx)(n.code,{children:"pubspec.yaml"})," to contain the ",(0,d.jsx)(n.code,{children:"todos_data_source"})," and ",(0,d.jsx)(n.code,{children:"in_memory_todos_data_source"})," dependencies:"]}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-yaml",children:"name: todos\ndescription: An example todos app built with Dart Frog.\nversion: 1.0.0+1\npublish_to: none\n\nenvironment:\n  sdk: '>=3.0.0 <4.0.0'\n\ndependencies:\n  dart_frog: ^1.0.0\n  in_memory_todos_data_source:\n    path: packages/in_memory_todos_data_source\n  todos_data_source:\n    path: packages/todos_data_source\n\ndev_dependencies:\n  http: ^1.0.0\n  mocktail: ^1.0.0\n  test: ^1.19.2\n  very_good_analysis: ^5.0.0\n"})}),"\n",(0,d.jsx)(n.p,{children:"Install the newly added dependencies via:"}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-bash",children:"dart pub get\n"})}),"\n",(0,d.jsx)(n.h2,{id:"creating-middleware",children:"Creating middleware"}),"\n",(0,d.jsxs)(n.p,{children:["Next, let's create a top-level piece of ",(0,d.jsx)(n.code,{children:"middleware"})," to provide the ",(0,d.jsx)(n.code,{children:"TodosDataSource"})," to all routes. Create ",(0,d.jsx)(n.code,{children:"routes/_middleware.dart"})," with the following contents:"]}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-dart",children:"import 'package:dart_frog/dart_frog.dart';\nimport 'package:in_memory_todos_data_source/in_memory_todos_data_source.dart';\n\nfinal _dataSource = InMemoryTodosDataSource();\n\nHandler middleware(Handler handler) {\n  return handler\n      .use(requestLogger())\n      .use(provider<TodosDataSource>((_) => _dataSource));\n}\n"})}),"\n",(0,d.jsxs)(n.admonition,{type:"info",children:[(0,d.jsxs)(n.p,{children:["We're providing a single instance of the ",(0,d.jsx)(n.code,{children:"TodosDataSource"})," so we have a single source of data for the lifetime of the application."]}),(0,d.jsxs)(n.p,{children:["In addition, we're using the ",(0,d.jsx)(n.code,{children:"requestLogger"})," middleware from ",(0,d.jsx)(n.code,{children:"package:dart_frog"})," to log all requests for debugging."]})]}),"\n",(0,d.jsx)(n.admonition,{type:"tip",children:(0,d.jsxs)(n.p,{children:["Install and use the ",(0,d.jsx)(n.a,{href:"https://marketplace.visualstudio.com/items?itemName=VeryGoodVentures.dart-frog",children:"Dart Frog VS Code extension"})," to easily create new middleware within your IDE."]})}),"\n",(0,d.jsxs)(n.h2,{id:"creating-the-todos-route",children:["Creating the ",(0,d.jsx)(n.code,{children:"/todos"})," route"]}),"\n",(0,d.jsxs)(n.p,{children:["Next, delete the root route handler at ",(0,d.jsx)(n.code,{children:"routes/index.dart"})," and create a route handler for the ",(0,d.jsx)(n.code,{children:"/todos"})," endpoint by creating ",(0,d.jsx)(n.code,{children:"routes/todos/index.dart"}),":"]}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-dart",children:"import 'dart:async';\nimport 'dart:io';\n\nimport 'package:dart_frog/dart_frog.dart';\nimport 'package:todos_data_source/todos_data_source.dart';\n\nFutureOr<Response> onRequest(RequestContext context) async {\n  switch (context.request.method) {\n    case HttpMethod.get:\n      return _get(context);\n    case HttpMethod.post:\n      return _post(context);\n    case HttpMethod.delete:\n    case HttpMethod.head:\n    case HttpMethod.options:\n    case HttpMethod.patch:\n    case HttpMethod.put:\n      return Response(statusCode: HttpStatus.methodNotAllowed);\n  }\n}\n\nFuture<Response> _get(RequestContext context) async {\n  final dataSource = context.read<TodosDataSource>();\n  final todos = await dataSource.readAll();\n  return Response.json(body: todos);\n}\n\nFuture<Response> _post(RequestContext context) async {\n  final dataSource = context.read<TodosDataSource>();\n  final todo = Todo.fromJson(\n    await context.request.json() as Map<String, dynamic>,\n  );\n\n  return Response.json(\n    statusCode: HttpStatus.created,\n    body: await dataSource.create(todo),\n  );\n}\n"})}),"\n",(0,d.jsx)(n.admonition,{type:"tip",children:(0,d.jsxs)(n.p,{children:["Install and use the ",(0,d.jsx)(n.a,{href:"https://marketplace.visualstudio.com/items?itemName=VeryGoodVentures.dart-frog",children:"Dart Frog VS Code extension"})," to easily create new routes within your IDE."]})}),"\n",(0,d.jsx)(n.admonition,{type:"note",children:(0,d.jsxs)(n.p,{children:["We're using ",(0,d.jsx)(n.code,{children:"context.read<TodosDataSource>"})," to access the provided instance of the ",(0,d.jsx)(n.code,{children:"TodosDataSource"}),"."]})}),"\n",(0,d.jsxs)(n.p,{children:["In this route handler, we only want to handle ",(0,d.jsx)(n.code,{children:"GET"})," and ",(0,d.jsx)(n.code,{children:"POST"})," requests so we're using a ",(0,d.jsx)(n.code,{children:"switch"})," statement on ",(0,d.jsx)(n.code,{children:"context.request.method"}),". If the ",(0,d.jsx)(n.code,{children:"HttpMethod"})," is not ",(0,d.jsx)(n.code,{children:"GET"})," or ",(0,d.jsx)(n.code,{children:"POST"}),", our route handler responds with a ",(0,d.jsx)(n.code,{children:"405"})," status code (method not allowed)."]}),"\n",(0,d.jsxs)(n.p,{children:["In addition, we're using the ",(0,d.jsx)(n.code,{children:"Response.json"})," constructor to respond with ",(0,d.jsx)(n.code,{children:"Content-Type: application/json"}),"."]}),"\n",(0,d.jsxs)(n.p,{children:["Next, we'll create a route handler for the ",(0,d.jsx)(n.code,{children:"/todos/<id>"})," endpoint so that we can handle operations for a specific todo."]}),"\n",(0,d.jsxs)(n.h2,{id:"creating-the-todosid-route",children:["Creating the ",(0,d.jsx)(n.code,{children:"/todos/<id>"})," route"]}),"\n",(0,d.jsxs)(n.p,{children:["We can create a dynamic route to handle matching and ",(0,d.jsx)(n.code,{children:"id"})," by creating a file called: ",(0,d.jsx)(n.code,{children:"routes/todos/[id].dart"}),"."]}),"\n",(0,d.jsx)(n.admonition,{type:"info",children:(0,d.jsxs)(n.p,{children:["Dynamic routes allow you to have one or more dynamic path segments in your route. Learn more about ",(0,d.jsx)(n.a,{href:"/docs/basics/routes#dynamic-routes-",children:"dynamic routes"}),"."]})}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-dart",children:"import 'dart:async';\nimport 'dart:io';\n\nimport 'package:dart_frog/dart_frog.dart';\nimport 'package:todos_data_source/todos_data_source.dart';\n\nFutureOr<Response> onRequest(RequestContext context, String id) async {\n  final dataSource = context.read<TodosDataSource>();\n  final todo = await dataSource.read(id);\n\n  if (todo == null) {\n    return Response(statusCode: HttpStatus.notFound, body: 'Not found');\n  }\n\n  switch (context.request.method) {\n    case HttpMethod.get:\n      return _get(context, todo);\n    case HttpMethod.put:\n      return _put(context, id, todo);\n    case HttpMethod.delete:\n      return _delete(context, id);\n    case HttpMethod.head:\n    case HttpMethod.options:\n    case HttpMethod.patch:\n    case HttpMethod.post:\n      return Response(statusCode: HttpStatus.methodNotAllowed);\n  }\n}\n\nFuture<Response> _get(RequestContext context, Todo todo) async {\n  return Response.json(body: todo);\n}\n\nFuture<Response> _put(RequestContext context, String id, Todo todo) async {\n  final dataSource = context.read<TodosDataSource>();\n  final updatedTodo = Todo.fromJson(\n    await context.request.json() as Map<String, dynamic>,\n  );\n  final newTodo = await dataSource.update(\n    id,\n    todo.copyWith(\n      title: updatedTodo.title,\n      description: updatedTodo.description,\n      isCompleted: updatedTodo.isCompleted,\n    ),\n  );\n\n  return Response.json(body: newTodo);\n}\n\nFuture<Response> _delete(RequestContext context, String id) async {\n  final dataSource = context.read<TodosDataSource>();\n  await dataSource.delete(id);\n  return Response(statusCode: HttpStatus.noContent);\n}\n"})}),"\n",(0,d.jsx)(n.admonition,{type:"note",children:(0,d.jsxs)(n.p,{children:[(0,d.jsx)(n.code,{children:"onRequest"})," now has two parameters: ",(0,d.jsx)(n.code,{children:"RequestContext"}),", and ",(0,d.jsx)(n.code,{children:"id"}),". The ",(0,d.jsx)(n.code,{children:"id"})," path segment is forwarded to the ",(0,d.jsx)(n.code,{children:"onRequest"})," method call."]})}),"\n",(0,d.jsxs)(n.p,{children:["Just like in the ",(0,d.jsx)(n.code,{children:"/todos"})," route handler, we are switching on the ",(0,d.jsx)(n.code,{children:"context.request.method"})," and selectively handling ",(0,d.jsx)(n.code,{children:"GET"}),", ",(0,d.jsx)(n.code,{children:"PUT"}),", and ",(0,d.jsx)(n.code,{children:"DELETE"})," requests."]}),"\n",(0,d.jsx)(n.h2,{id:"summary",children:"Summary"}),"\n",(0,d.jsx)(n.p,{children:"Be sure to save all the changes and hot reload should kick in \u26a1\ufe0f"}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-bash",children:"[hotreload] - Application reloaded.\n"})}),"\n",(0,d.jsx)(n.p,{children:"You should now be able to make requests to create, read, update, and delete todos:"}),"\n",(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-bash",children:'# Create a new todo\ncurl --request POST \\\n  --url http://localhost:8080/todos \\\n  --header \'Content-Type: application/json\' \\\n  --data \'{\n  "title": "Take out trash"\n}\'\n\n# Read all todos\ncurl --request GET \\\n  --url http://localhost:8080/todos\n\n# Read a specific todo by id\ncurl --request GET \\\n  --url http://localhost:8080/todos/<id>\n\n# Update a specific todo by id\ncurl --request PUT \\\n  --url http://localhost:8080/todos/<id> \\\n  --header \'Content-Type: application/json\' \\\n  --data \'{\n  "title": "Take out trash!",\n  "isCompleted": true\n}\'\n\n# Delete a specific todo by id\ncurl --request DELETE \\\n  --url http://localhost:8080/todos/<id>\n'})}),"\n",(0,d.jsxs)(n.admonition,{type:"note",children:[(0,d.jsxs)(n.p,{children:["You should see detailed request logs in the console due to the ",(0,d.jsx)(n.code,{children:"requestLogger"})," middleware that look similar to:"]}),(0,d.jsx)(n.pre,{children:(0,d.jsx)(n.code,{className:"language-bash",children:"2022-08-09T17:43:35.816387  0:00:00.016484 GET     [200] /todos\n2022-08-09T17:44:05.561021  0:00:00.022465 POST    [201] /todos\n"})})]}),"\n",(0,d.jsxs)(n.p,{children:["\ud83c\udf89 Congrats, you've created a ",(0,d.jsx)(n.code,{children:"todos"})," application using Dart Frog. View the ",(0,d.jsx)(n.a,{href:"https://github.com/VeryGoodOpenSource/dart_frog/tree/main/examples/todos",children:"full source code"}),"."]})]})}function h(e={}){const{wrapper:n}={...(0,a.R)(),...e.components};return n?(0,d.jsx)(n,{...e,children:(0,d.jsx)(l,{...e})}):l(e)}},8453:(e,n,t)=>{t.d(n,{R:()=>s,x:()=>r});var o=t(6540);const d={},a=o.createContext(d);function s(e){const n=o.useContext(a);return o.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function r(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(d):e.components||d:s(e.components),o.createElement(a.Provider,{value:n},e.children)}}}]);