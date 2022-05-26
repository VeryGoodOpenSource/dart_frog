import 'dart:io';

import 'package:dart_frog_gen/src/path_to_route.dart';
import 'package:path/path.dart' as path;

/// Build a [RouteConfiguration] based on the provided root project [directory].
RouteConfiguration buildRouteConfiguration(Directory directory) {
  final routesDirectory = Directory(path.join(directory.path, 'routes'));

  if (!routesDirectory.existsSync()) {
    throw Exception('Could not find directory ${routesDirectory.path}');
  }

  final globalMiddlewareFile = File(
    path.join(routesDirectory.path, '_middleware.dart'),
  );
  final globalMiddleware = globalMiddlewareFile.existsSync()
      ? MiddlewareFile(
          name: 'routes_middleware',
          path: path
              .join('..', path.relative(globalMiddlewareFile.path))
              .replaceAll(r'\', '/'),
        )
      : null;

  final middleware = <MiddlewareFile>[
    if (globalMiddleware != null) globalMiddleware
  ];
  final routes = <RouteFile>[];
  final directories = _getRouteDirectories(
    routesDirectory,
    onRoute: routes.add,
    onMiddleware: middleware.add,
  );

  return RouteConfiguration(
    globalMiddleware: globalMiddleware,
    middleware: middleware,
    directories: directories,
    routes: routes,
  );
}

List<RouteDirectory> _getRouteDirectories(
  Directory directory, {
  void Function(RouteFile route)? onRoute,
  void Function(MiddlewareFile route)? onMiddleware,
}) {
  final directories = <RouteDirectory>[];
  final entities = directory.listSync();
  final directorySegment =
      directory.path.split('routes').last.replaceAll(r'\', '/');
  final directoryPath = directorySegment.startsWith('/')
      ? directorySegment
      : '/$directorySegment';
  // Only add nested middleware -- global middleware is added separately.
  MiddlewareFile? middleware;
  if (directory.path != path.join(Directory.current.path, 'routes')) {
    final _middleware = File(path.join(directory.path, '_middleware.dart'));
    if (_middleware.existsSync()) {
      final middlewarePath = path
          .join('..', path.relative(_middleware.path))
          .replaceAll(r'\', '/');
      middleware = MiddlewareFile(
        name: middlewarePath.toAlias(),
        path: middlewarePath,
      );
      onMiddleware?.call(middleware);
    }
  }

  final files = [
    ..._getRouteFiles(directory, onRoute: onRoute),
    ..._getRouteFilesForDynamicDirectories(directory, onRoute: onRoute),
  ];

  directories.add(
    RouteDirectory(
      name: directoryPath.toAlias(),
      route: directoryPath.toRoute(),
      middleware: middleware,
      files: files,
    ),
  );

  entities.whereType<Directory>().forEach((entity) {
    if (!entity.isDynamicRoute) {
      directories.addAll(
        _getRouteDirectories(
          entity,
          onRoute: onRoute,
          onMiddleware: onMiddleware,
        ),
      );
    }
  });

  return directories;
}

List<RouteFile> _getRouteFilesForDynamicDirectories(
  Directory directory, {
  void Function(RouteFile route)? onRoute,
  String prefix = '',
}) {
  final files = <RouteFile>[];
  directory
      .listSync()
      .whereType<Directory>()
      .where((d) => d.isDynamicRoute)
      .forEach((dynamicDirectory) {
    final newPrefix = '/${path.basename(dynamicDirectory.path)}$prefix';
    final subset = _getRouteFiles(
      dynamicDirectory,
      onRoute: onRoute,
      prefix: newPrefix,
    );
    final dynamicSubset = _getRouteFilesForDynamicDirectories(
      dynamicDirectory,
      onRoute: onRoute,
      prefix: newPrefix,
    );
    files.addAll([...subset, ...dynamicSubset]);
  });
  return files;
}

List<RouteFile> _getRouteFiles(
  Directory directory, {
  void Function(RouteFile route)? onRoute,
  String prefix = '',
}) {
  final files = <RouteFile>[];
  final directorySegment =
      directory.path.split('routes').last.replaceAll(r'\', '/');
  final directoryPath = directorySegment.startsWith('/')
      ? directorySegment
      : '/$directorySegment';
  final entities = directory.listSync();
  entities.where((e) => e.isRoute).cast<File>().forEach((entity) {
    final filePath =
        path.join('..', path.relative(entity.path)).replaceAll(r'\', '/');
    final fileRoutePath = pathToRoute(filePath).split(directoryPath).last;
    var fileRoute = fileRoutePath.isEmpty ? '/' : fileRoutePath;
    fileRoute = prefix + fileRoute;
    if (!fileRoute.startsWith('/')) {
      fileRoute = '/$fileRoute';
    }
    if (fileRoute != '/' && fileRoute.endsWith('/')) {
      fileRoute = fileRoute.substring(0, fileRoute.length - 1);
    }

    final route = RouteFile(
      name: filePath.toAlias(),
      path: filePath,
      route: fileRoute.toRoute(),
    );
    onRoute?.call(route);
    files.add(route);
  });
  return files;
}

extension on String {
  String toAlias() {
    final alias = path
        .withoutExtension(this)
        .replaceAll('[', r'$')
        .replaceAll(']', '')
        .replaceAll('/', '_');
    if (alias == '') return 'index';
    return alias;
  }

  String toRoute() {
    return replaceAll('[', '<').replaceAll(']', '>').replaceAll(r'\', '/');
  }
}

extension on Directory {
  bool get isDynamicRoute {
    return RegExp(r'\[(.*)\]').hasMatch(path.basename(this.path));
  }
}

extension on FileSystemEntity {
  bool get isRoute {
    return this is File &&
        path.basename(this.path).endsWith('.dart') &&
        path.basename(this.path) != '_middleware.dart';
  }
}

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
  });

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
  });

  /// The alias for the current directory.
  final String name;

  /// The route which will be used to mount routers.
  final String route;

  /// Optional middleware for the provided router.
  final MiddlewareFile? middleware;

  /// A list of nested route files within the directory.
  final List<RouteFile> files;

  /// Create a copy of the current instance and override zero or more values.
  RouteDirectory copyWith({
    String? name,
    String? route,
    MiddlewareFile? middleware,
    List<RouteFile>? files,
  }) {
    return RouteDirectory(
      name: name ?? this.name,
      route: route ?? this.route,
      middleware: middleware ?? this.middleware,
      files: files ?? this.files,
    );
  }

  /// Convert the current instance to a `Map<String, dynamic>`.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'route': route,
      'middleware': middleware?.toJson() ?? false,
      'files': files.map((f) => f.toJson()).toList(),
    };
  }
}

/// {@template route_file}
/// A class containing metadata regarding a route directory.
/// {@endtemplate}
class RouteFile {
  /// {@macro route_file}
  const RouteFile({
    required this.name,
    required this.path,
    required this.route,
  });

  /// The alias for the current directory.
  final String name;

  /// The import path for the current instance.
  final String path;

  /// The route used by router instances.
  final String route;

  /// Create a copy of the current instance and override zero or more values.
  RouteFile copyWith({String? name, String? path, String? route}) {
    return RouteFile(
      name: name ?? this.name,
      path: path ?? this.path,
      route: route ?? this.route,
    );
  }

  /// Convert the current instance to a `Map<String, dynamic>`.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'path': path,
      'route': route,
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
