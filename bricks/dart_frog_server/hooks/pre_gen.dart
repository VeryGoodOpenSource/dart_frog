import 'dart:io';

import 'package:dart_frog/dart_frog.dart' show pathToRoute;
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

Future<void> run(HookContext context) async {
  final routesDirectory =
      Directory(path.join(Directory.current.path, 'routes'));

  if (!routesDirectory.existsSync()) {
    context.logger.err('Could not find directory ${routesDirectory.path}');
    exit(1);
  }

  final routes = <RouteFile>[];
  final middleware = <MiddlewareFile>[];
  final directories = buildGraph(
    routesDirectory,
    onRoute: routes.add,
    onMiddleware: middleware.add,
  );

  context.vars = {
    'directories': directories.map((c) => c.toJson()).toList(),
    'routes': routes.map((r) => r.toJson()).toList(),
    'middleware': middleware.map((m) => m.toJson()).toList(),
  };
}

List<RouteDirectory> buildGraph(
  Directory directory, {
  void Function(RouteFile route)? onRoute,
  void Function(MiddlewareFile route)? onMiddleware,
  int depth = 0,
}) {
  depth++;
  final directories = <RouteDirectory>[];
  final entities = directory.listSync();
  final directorySegment = directory.path.split('routes').last;
  final directoryPath = directorySegment.startsWith('/')
      ? directorySegment
      : '/$directorySegment';

  final files = <RouteFile>[];
  var fileDepth = depth;
  entities.where((e) => e.isRoute).cast<File>().forEach((entity) {
    final filePath = path.join(
      '..',
      path.relative(entity.path).replaceAll(r'\', '/'),
    );
    final fileRoute = pathToRoute(filePath).split(directoryPath).last;
    final route = RouteFile(
      name: 'r$fileDepth',
      path: filePath,
      route: fileRoute.isEmpty
          ? '/'
          : fileRoute.startsWith('/')
              ? fileRoute
              : '/$fileRoute',
    );
    onRoute?.call(route);
    files.add(route);
    fileDepth++;
  });

  MiddlewareFile? middleware;
  final _middleware = File(path.join(directory.path, '_middleware.dart'));
  if (_middleware.existsSync()) {
    final middlewarePath = path.join(
      '..',
      path.relative(_middleware.path).replaceAll(r'\', '/'),
    );
    middleware = MiddlewareFile(name: 'm$depth', path: middlewarePath);
    onMiddleware?.call(middleware);
  }

  directories.add(
    RouteDirectory(
      name: 'd$depth',
      path: directoryPath,
      middleware: middleware,
      files: files,
    ),
  );

  entities.whereType<Directory>().forEach((entity) {
    directories.addAll(
      buildGraph(
        entity,
        onRoute: onRoute,
        onMiddleware: onMiddleware,
        depth: depth,
      ),
    );
  });

  return directories;
}

extension on FileSystemEntity {
  bool get isRoute {
    return this is File &&
        path.basename(this.path).endsWith('.dart') &&
        path.basename(this.path) != '_middleware.dart';
  }
}

class RouteDirectory {
  const RouteDirectory({
    required this.name,
    required this.path,
    required this.middleware,
    required this.files,
  });

  final String name;
  final String path;
  final MiddlewareFile? middleware;
  final List<RouteFile> files;

  RouteDirectory copyWith({
    String? name,
    String? path,
    MiddlewareFile? middleware,
    List<RouteFile>? files,
  }) {
    return RouteDirectory(
      name: name ?? this.name,
      path: path ?? this.path,
      middleware: middleware ?? this.middleware,
      files: files ?? this.files,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'path': path,
      'middleware': middleware?.toJson() ?? null,
      'files': files.map((f) => f.toJson()).toList(),
    };
  }
}

class RouteFile {
  const RouteFile({
    required this.name,
    required this.path,
    required this.route,
  });

  final String name;
  final String path;
  final String route;

  RouteFile copyWith({String? name, String? path, String? route}) {
    return RouteFile(
      name: name ?? this.name,
      path: path ?? this.path,
      route: route ?? this.route,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'path': path,
      'route': route,
    };
  }
}

class MiddlewareFile {
  const MiddlewareFile({
    required this.name,
    required this.path,
  });

  final String name;
  final String path;

  MiddlewareFile copyWith({String? name, String? path}) {
    return MiddlewareFile(
      name: name ?? this.name,
      path: path ?? this.path,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'path': path,
    };
  }
}
