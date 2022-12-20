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
    resources.add(
      _getResourcesForDirectory(
        directory: directory,
        routesDirectory: routesDirectory,
      ),
    );
  }

  final indexEndpointIndex = endpoints.indexWhere((e) => e.name == 'index');
  final extendsEndpoint = indexEndpointIndex != -1;
  final normalizedEndpoints = extendsEndpoint
      ? ([...endpoints]..removeAt(indexEndpointIndex))
      : endpoints;

  return ClientConfiguration(
    packageName: packageName,
    endpoints: normalizedEndpoints,
    resources: resources,
    extendsEndpoint: extendsEndpoint,
  );
}

List<ClientEndpoint> _getEndpointsForDirectory({
  required Directory directory,
  required Directory routesDirectory,
}) {
  final routes = directory.listSync().where((e) => e.isRoute);
  return routes.map((entity) => entity.toEndpoint(routesDirectory)).toList();
}

ClientResource _getResourcesForDirectory({
  required Directory directory,
  required Directory routesDirectory,
}) {
  final endpoints = _getEndpointsForDirectory(
    directory: directory,
    routesDirectory: routesDirectory,
  );

  final resources = <ClientResource>[];
  directory.listSync().whereType<Directory>().forEach((directory) {
    resources.add(
      _getResourcesForDirectory(
        directory: directory,
        routesDirectory: routesDirectory,
      ),
    );
  });

  return directory.toResource(endpoints: endpoints, resources: resources);
}

extension on String {
  String toEndpoint() {
    final endpoint = path
        .basenameWithoutExtension(this)
        .replaceFirst('[', 'by_')
        .replaceAll('[', 'and_')
        .replaceAll(']', '')
        .replaceAll(RegExp(r'(\\+)'), '_')
        .replaceAll(RegExp('(/+)'), '_');
    if (endpoint.isEmpty || endpoint == '_') return 'index';
    return endpoint;
  }

  String toResource() {
    if (this == '/') return 'root';
    return path
        .withoutExtension(this)
        .replaceFirst('[', 'by_')
        .replaceAll('[', 'and_')
        .replaceAll(']', '')
        .replaceAll(RegExp(r'(\\+)'), '_')
        .replaceAll(RegExp('(/+)'), '_');
  }

  String toRequestPath() {
    return replaceAll('<', r'$')
        .replaceAll('>', '')
        .replaceAll('[', r'${')
        .replaceAll(']', '}')
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

    final indexEndpointIndex = endpoints.indexWhere((e) => e.name == 'index');
    final extendsEndpoint = indexEndpointIndex != -1;
    final normalizedEndpoints = extendsEndpoint
        ? ([...endpoints]..removeAt(indexEndpointIndex))
        : endpoints;

    return ClientResource(
      name: fullDirectoryPath.toResource(),
      method: directoryPath.toResource(),
      extendsEndpoint: extendsEndpoint,
      params: directoryPath.toParams(),
      path: directoryPath.toRequestPath(),
      endpoints: normalizedEndpoints,
      resources: resources,
    );
  }
}
