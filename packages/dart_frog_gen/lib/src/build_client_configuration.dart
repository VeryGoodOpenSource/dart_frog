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

  final resourcesFlat = <ClientResource>[];
  final resources = <ClientResource>[];

  void onResource(ClientResource resource) => resourcesFlat.add(resource);

  for (final directory in routesDirectory.listSync().whereType<Directory>()) {
    final resource = _getResourceForDirectory(
      directory: directory,
      routesDirectory: routesDirectory,
      onResource: onResource,
    );
    resources.add(resource);
    onResource(resource);
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
    resourcesFlat: resourcesFlat,
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

ClientResource _getResourceForDirectory({
  required Directory directory,
  required Directory routesDirectory,
  required void Function(ClientResource resource) onResource,
}) {
  final endpoints = _getEndpointsForDirectory(
    directory: directory,
    routesDirectory: routesDirectory,
  );

  final resources = <ClientResource>[];
  directory.listSync().whereType<Directory>().forEach((directory) {
    final resource = _getResourceForDirectory(
      directory: directory,
      routesDirectory: routesDirectory,
      onResource: onResource,
    );
    resources.add(resource);
    onResource(resource);
  });

  return directory.toResource(endpoints: endpoints, resources: resources);
}

extension on String {
  String toEndpoint() {
    final endpoint = path
        .basenameWithoutExtension(this)
        .replaceAll('[', '_')
        .replaceAll(']', '')
        .replaceAll(RegExp(r'(\\+)'), '_')
        .replaceAll(RegExp('(/+)'), '_')
        .replaceAll(RegExp('(_+)'), '_');
    if (endpoint.isEmpty || endpoint == '_') return 'index';
    return endpoint;
  }

  String toResource() {
    final resource = path
        .withoutExtension(this)
        .replaceAll('[', '_')
        .replaceAll(']', '')
        .replaceAll(RegExp(r'(\\+)'), '_')
        .replaceAll(RegExp('(/+)'), '_')
        .replaceAll(RegExp('(_+)'), '_');
    if (resource.isEmpty || resource == '_') return 'root';
    return resource;
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
