import 'package:path/path.dart' as path;

/// {@template route_configuration}
/// An object containing all route configuration metadata
/// required to generate a dart frog server.
/// {@endtemplate}
class RouteConfiguration {
  /// {@macro route_configuration}
  const RouteConfiguration({
    this.globalMiddleware,
    required this.middleware,
    required this.directories,
    required this.routes,
    required this.endpoints,
    required this.rogueRoutes,
    this.serveStaticFiles = false,
    this.invokeCustomEntrypoint = false,
  });

  /// Whether to invoke a custom entrypoint script (`main.dart`).
  final bool invokeCustomEntrypoint;

  /// Whether to serve static files. Defaults to false.
  final bool serveStaticFiles;

  /// Optional global middleware.
  final MiddlewareFile? globalMiddleware;

  /// List of all nested middleware.
  /// Top-level middleware is excluded (see [globalMiddleware]).
  final List<MiddlewareFile> middleware;

  /// List of all route directories.
  /// Sorted from leaf nodes to root.
  final List<RouteDirectory> directories;

  /// List of all route files.
  final List<RouteFile> routes;

  /// A map of all endpoint paths to resolved route files.
  final Map<String, List<RouteFile>> endpoints;

  /// List of all rogue routes.
  ///
  /// A route is considered rogue when it is defined outside
  /// of an existing subdirectory with the same name.
  ///
  /// For example:
  ///
  /// ```
  /// ├── routes
  /// │   ├── foo
  /// │   │   └── example.dart
  /// │   ├── foo.dart
  /// ```
  ///
  /// In the above scenario, `foo.dart` is rogue because it is defined
  /// outside of the existing `foo` directory.
  ///
  /// Instead, `foo.dart` should be renamed to `index.dart` and placed within
  /// the `foo` directory like:
  ///
  /// ```
  /// ├── routes
  /// │   ├── foo
  /// │   │   ├── example.dart
  /// │   │   └── index.dart
  /// ```
  final List<RouteFile> rogueRoutes;
}

/// {@template route_directory}
/// A class containing metadata regarding a route directory.
/// {@endtemplate}
class RouteDirectory {
  /// {@macro route_directory}
  const RouteDirectory({
    required this.name,
    required this.route,
    required this.middleware,
    required this.files,
    required this.params,
  });

  /// The alias for the current directory.
  final String name;

  /// The route which will be used to mount routers.
  final String route;

  /// The dynamic route params associated with the directory.
  final List<String> params;

  /// List of middleware for the provided router.
  final List<MiddlewareFile> middleware;

  /// A list of nested route files within the directory.
  final List<RouteFile> files;

  /// Create a copy of the current instance and override zero or more values.
  RouteDirectory copyWith({
    String? name,
    String? route,
    List<MiddlewareFile>? middleware,
    List<RouteFile>? files,
    List<String>? params,
  }) {
    return RouteDirectory(
      name: name ?? this.name,
      route: route ?? this.route,
      middleware: middleware ?? this.middleware,
      files: files ?? this.files,
      params: params ?? this.params,
    );
  }

  /// Convert the current instance to a `Map<String, dynamic>`.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'resource_name': route.toResource(),
      'route': route,
      'request_path': route.toRequestPath(),
      'middleware': middleware.map((m) => m.toJson()).toList(),
      'files': files.map((f) => f.toJson()).toList(),
      'directory_params': params,
    };
  }
}

/// {@template route_file}
/// A class containing metadata regarding a route file.
/// {@endtemplate}
class RouteFile {
  /// {@macro route_file}
  const RouteFile({
    required this.name,
    required this.path,
    required this.route,
    required this.params,
  });

  /// The alias for the current file.
  final String name;

  /// The import path for the current instance.
  final String path;

  /// The route used by router instances.
  final String route;

  /// The dynamic route params associated with the file.
  final List<String> params;

  /// Create a copy of the current instance and override zero or more values.
  RouteFile copyWith({
    String? name,
    String? path,
    String? route,
    List<String>? params,
  }) {
    return RouteFile(
      name: name ?? this.name,
      path: path ?? this.path,
      route: route ?? this.route,
      params: params ?? this.params,
    );
  }

  /// Convert the current instance to a `Map<String, dynamic>`.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'endpoint_name': route.toEndpoint(),
      'path': path,
      'route': route,
      'request_path': route.toRequestPath(),
      'file_params': params,
    };
  }
}

/// {@template middleware_file}
/// A class containing metadata regarding a route directory.
/// {@endtemplate}
class MiddlewareFile {
  /// {@macro middleware_file}
  const MiddlewareFile({
    required this.name,
    required this.path,
  });

  /// The alias for the current directory.
  final String name;

  /// The import path for the current instance.
  final String path;

  /// Create a copy of the current instance and override zero or more values.
  MiddlewareFile copyWith({String? name, String? path}) {
    return MiddlewareFile(
      name: name ?? this.name,
      path: path ?? this.path,
    );
  }

  /// Convert the current instance to a `Map<String, dynamic>`.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'path': path,
    };
  }
}

extension on String {
  String toResource() {
    if (this == '/') return 'root';
    return path
        .withoutExtension(this)
        .replaceAll('<', 'by_')
        .replaceAll('>', '')
        .replaceAll('/', '_');
  }

  String toEndpoint() {
    final endpoint = path
        .basenameWithoutExtension(this)
        .replaceAll('<', 'by_')
        .replaceAll('>', '')
        .replaceAll(r'\', '_')
        .replaceAll('/', '_');
    if (endpoint.isEmpty || endpoint == '_') return 'index';
    return endpoint;
  }

  String toRequestPath() {
    return replaceAll('<', r'$')
        .replaceAll('>', '')
        .replaceAll('[', r'$')
        .replaceAll(']', '')
        .replaceAll(r'\', '/');
  }
}
