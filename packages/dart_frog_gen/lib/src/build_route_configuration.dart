import 'dart:io';

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:dart_frog_gen/src/extensions/extensions.dart';
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
          name: 'middleware',
          path: path
              .join('..', path.relative(globalMiddlewareFile.path))
              .replaceAll(r'\', '/'),
        )
      : null;

  final endpoints = <String, List<RouteFile>>{};
  final middleware = <MiddlewareFile>[
    if (globalMiddleware != null) globalMiddleware
  ];
  final routes = <RouteFile>[];
  final rogueRoutes = <RouteFile>[];
  final directories = _getRouteDirectories(
    directory: routesDirectory,
    routesDirectory: routesDirectory,
    onRoute: routes.add,
    onMiddleware: middleware.add,
    onEndpoint: (endpoint, file) {
      if (!endpoints.containsKey(endpoint)) {
        endpoints[endpoint] = [file];
      } else {
        endpoints[endpoint]!.add(file);
      }
    },
    onRogueRoute: rogueRoutes.add,
  );
  final publicDirectory = Directory(path.join(directory.path, 'public'));
  final mainDartFile = File(path.join(directory.path, 'main.dart'));

  final customInitRegex = RegExp(
    r'^Future(?:Or)?<void>\s*init\(InternetAddress .*?,\s*int .*?\)\s*(?:async)?\s*{',
    multiLine: true,
  );

  final mainDartFileExists = mainDartFile.existsSync();
  final hasCustomInit = mainDartFileExists &&
      customInitRegex.hasMatch(mainDartFile.readAsStringSync());

  return RouteConfiguration(
    globalMiddleware: globalMiddleware,
    middleware: middleware,
    directories: directories,
    routes: routes,
    rogueRoutes: rogueRoutes,
    endpoints: endpoints,
    serveStaticFiles: publicDirectory.existsSync(),
    invokeCustomEntrypoint: mainDartFileExists,
    invokeCustomInit: hasCustomInit,
  );
}

List<RouteDirectory> _getRouteDirectories({
  required Directory directory,
  required Directory routesDirectory,
  required void Function(RouteFile route) onRoute,
  required void Function(MiddlewareFile route) onMiddleware,
  required void Function(String endpoint, RouteFile file) onEndpoint,
  required void Function(RouteFile route) onRogueRoute,
  List<MiddlewareFile> middleware = const [],
}) {
  final directories = <RouteDirectory>[];
  final entities = directory.listSync().sorted();
  final directorySegment =
      directory.path.split('routes').last.replaceAll(r'\', '/');
  final directoryPath = directorySegment.startsWith('/')
      ? directorySegment
      : '/$directorySegment';
  // Only add nested middleware -- global middleware is added separately.
  MiddlewareFile? localMiddleware;
  if (directory.path != path.join(Directory.current.path, 'routes')) {
    final middlewareFile = File(path.join(directory.path, '_middleware.dart'));
    if (middlewareFile.existsSync()) {
      final middlewarePath = path
          .relative(middlewareFile.path, from: routesDirectory.path)
          .replaceAll(r'\', '/');
      localMiddleware = MiddlewareFile(
        name: middlewarePath.toAlias(),
        path: path.join('..', 'routes', middlewarePath).replaceAll(r'\', '/'),
      );
      onMiddleware(localMiddleware);
    }
  }

  final updatedMiddleware = [
    ...middleware,
    if (localMiddleware != null) localMiddleware,
  ];

  final files = _getRouteFiles(
    directory: directory,
    routesDirectory: routesDirectory,
    onRoute: onRoute,
    onRogueRoute: onRogueRoute,
  );

  if (files.isNotEmpty) {
    final baseRoute = directoryPath.toRoute();
    for (final file in files) {
      var endpoint = (baseRoute + file.route.toRoute()).replaceAll('//', '/');
      if (endpoint.endsWith('/')) {
        endpoint = endpoint.substring(0, endpoint.length - 1);
      }
      if (endpoint.isEmpty) endpoint = '/';
      onEndpoint(endpoint, file);
    }

    directories.add(
      RouteDirectory(
        name: directoryPath.toAlias(),
        route: baseRoute,
        middleware: updatedMiddleware,
        files: files,
        params: directoryPath.toParams(),
      ),
    );
  }

  entities.whereType<Directory>().forEach((directory) {
    directories.addAll(
      _getRouteDirectories(
        directory: directory,
        routesDirectory: routesDirectory,
        onRoute: onRoute,
        onMiddleware: onMiddleware,
        onEndpoint: onEndpoint,
        onRogueRoute: onRogueRoute,
        middleware: updatedMiddleware,
      ),
    );
  });

  return directories;
}

List<RouteFile> _getRouteFiles({
  required Directory directory,
  required Directory routesDirectory,
  required void Function(RouteFile route) onRoute,
  required void Function(RouteFile route) onRogueRoute,
  String prefix = '',
}) {
  final files = <RouteFile>[];
  final directorySegment =
      directory.path.split('routes').last.replaceAll(r'\', '/');
  final directoryPath = directorySegment.startsWith('/')
      ? directorySegment
      : '/$directorySegment';
  final entities = directory.listSync().sorted();
  final subDirectories = entities
      .whereType<Directory>()
      .map((directory) => path.basename(directory.path))
      .toSet();
  entities.where((e) => e.isRoute).cast<File>().forEach((entity) {
    final filePath = path
        .relative(entity.path, from: routesDirectory.path)
        .replaceAll(r'\', '/');

    String getFileRoute() {
      final routePath = pathToRoute(path.join('..', 'routes', filePath));
      final index = routePath.indexOf(directoryPath);
      final fileRoutePath = index == -1
          ? routePath
          : routePath.substring(index + directoryPath.length);

      var fileRoute = fileRoutePath.isEmpty ? '/' : fileRoutePath;
      fileRoute = prefix + fileRoute;

      if (!fileRoute.startsWith('/')) fileRoute = '/$fileRoute';

      return fileRoute;
    }

    final fileRoute = getFileRoute();
    final relativeFilePath = path.join('..', 'routes', filePath);
    final route = RouteFile(
      name: filePath.toAlias(),
      path: relativeFilePath.replaceAll(r'\', '/'),
      route: fileRoute.toRoute(),
      params: fileRoute.toParams(),
    );
    onRoute(route);
    files.add(route);

    final fileBasename = path.basenameWithoutExtension(filePath);
    final conflictingIndexFile = File(
      path.join(directory.path, fileBasename, 'index.dart'),
    );
    final isRogueRoute = subDirectories.contains(fileBasename) &&
        !conflictingIndexFile.existsSync();

    if (isRogueRoute) onRogueRoute(route);
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

extension on List<FileSystemEntity> {
  List<FileSystemEntity> sorted() {
    return this..sort((a, b) => b.path.compareTo(a.path));
  }
}
