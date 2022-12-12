import 'dart:io';

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:dart_frog_gen/src/extensions/extensions.dart';
import 'package:dart_frog_gen/src/path_to_route.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';

/// Build a [ClientConfiguration] based on
/// the provided root project [directory].
ClientConfiguration buildClientConfiguration(Directory directory) {
  final routesDirectory = Directory(path.join(directory.path, 'routes'));

  if (!routesDirectory.existsSync()) {
    throw Exception('Could not find directory ${routesDirectory.path}');
  }

  final pubspecFile = File(path.join(directory.path, 'pubspec.yaml'));
  if (!pubspecFile.existsSync()) {
    throw Exception('Could not find a pubspec.yaml at ${pubspecFile.path}');
  }

  final pubspec = Pubspec.parse(pubspecFile.readAsStringSync());
  final packageName = '${pubspec.name}_client';

  final endpoints = [
    ..._getEndpointsForDirectory(
      directory: routesDirectory,
      routesDirectory: routesDirectory,
    )
  ];

  final resources = <ClientResource>[];
  for (final directory in routesDirectory.listSync().whereType<Directory>()) {
    resources.addAll(
      _getResourcesForDirectory(
        directory: directory,
        routesDirectory: routesDirectory,
      ),
    );
  }

  return ClientConfiguration(
    packageName: packageName,
    endpoints: endpoints,
    resources: resources,
  );
}

List<ClientEndpoint> _getEndpointsForDirectory({
  required Directory directory,
  required Directory routesDirectory,
}) {
  final routes = directory.listSync().where((e) => e.isRoute);
  return routes.map((entity) => entity.toEndpoint(routesDirectory)).toList();
}

List<ClientResource> _getResourcesForDirectory({
  required Directory directory,
  required Directory routesDirectory,
}) {
  final endpoints = _getEndpointsForDirectory(
    directory: directory,
    routesDirectory: routesDirectory,
  );

  var resource = directory.toResource(endpoints: endpoints);

  directory.listSync().whereType<Directory>().forEach((directory) {
    resource = resource.copyWith(
      resources: _getResourcesForDirectory(
        directory: directory,
        routesDirectory: routesDirectory,
      ),
    );
  });

  return [resource];
}

extension on String {
  String toEndpoint() {
    final endpoint = path
        .basenameWithoutExtension(this)
        .replaceAll('[', 'by_')
        .replaceAll(']', '')
        .replaceAll(r'\', '_')
        .replaceAll('/', '_');
    if (endpoint.isEmpty || endpoint == '_') return 'index';
    return endpoint;
  }

  String toResource() {
    if (this == '/') return 'root';
    return path
        .withoutExtension(this)
        .replaceAll('[', 'by_')
        .replaceAll(']', '')
        .replaceAll('/', '_');
  }

  String toRequestPath() {
    return replaceAll('<', r'$')
        .replaceAll('>', '')
        .replaceAll('[', r'$')
        .replaceAll(']', '')
        .replaceAll(r'\', '/');
  }
}

extension on FileSystemEntity {
  String toFileRoute(Directory routesDirectory) {
    final filePath = path.basenameWithoutExtension(
      path
          .relative(this.path, from: routesDirectory.path)
          .replaceAll(r'\', '/'),
    );
    final directorySegment =
        Directory.current.path.split('routes').last.replaceAll(r'\', '/');
    final directoryPath = directorySegment.startsWith('/')
        ? directorySegment
        : '/$directorySegment';
    final routePath = pathToRoute(path.join('..', 'routes', filePath));
    final index = routePath.indexOf(directoryPath);
    final fileRoutePath = index == -1
        ? routePath
        : routePath.substring(index + directoryPath.length);

    var fileRoute = fileRoutePath.isEmpty ? '/' : fileRoutePath;

    if (!fileRoute.startsWith('/')) fileRoute = '/$fileRoute';

    return fileRoute;
  }

  ClientEndpoint toEndpoint(Directory routesDirectory) {
    final fileRoute = toFileRoute(routesDirectory);
    return ClientEndpoint(
      name: fileRoute.toEndpoint(),
      path: fileRoute.toRequestPath(),
      params: fileRoute.toParams(),
    );
  }

  ClientResource toResource({
    List<ClientEndpoint> endpoints = const [],
    List<ClientResource> resources = const [],
  }) {
    final fullDirectoryPath =
        this.path.split('routes').last.replaceAll(r'\', '/');
    final directorySegment = path.basenameWithoutExtension(fullDirectoryPath);
    final directoryPath = directorySegment.startsWith('/')
        ? directorySegment
        : '/$directorySegment';

    return ClientResource(
      name: fullDirectoryPath.toResource(),
      method: directoryPath.toResource(),
      params: directoryPath.toParams(),
      path: directoryPath.toRequestPath(),
      endpoints: endpoints,
      resources: resources,
    );
  }
}
