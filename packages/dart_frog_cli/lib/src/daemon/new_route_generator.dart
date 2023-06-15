import 'dart:io';

import 'package:dart_frog_cli/src/daemon/daemon.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import '../commands/new/templates/dart_frog_new_bundle.dart';

class NewRouteGenerator {
  NewRouteGenerator({
    required this.logger,
    required this.workingDirectory,
    GeneratorBuilder generator = MasonGenerator.fromBundle,
  }) : _generatorBuilder = generator;

  final GeneratorBuilder _generatorBuilder;
  final Logger logger;
  final String workingDirectory;

  void validateRoutePath(String routePath) {
    if (routePath.isEmpty) {
      throw RouteValidationException(
        'Route path must not be empty',
      );
    }

    final segments =
        routePath.split('/').skipWhile((element) => element.isEmpty);

    for (final segment in segments) {
      if (segment.isEmpty) {
        throw RouteValidationException(
          'Route path cannot contain empty segments',
        );
      }
      if (segment.contains(r'$')) {
        throw RouteValidationException(
          'Route path cannot contain dollar signs',
        );
      }
      if (segment.contains(RegExp(r'[^a-zA-Z\d_\[\]]'))) {
        throw RouteValidationException(
          'Route path segments must be valid Dart identifiers',
        );
      }
    }
  }

  /// This may throw [RouteValidationException]
  Future<void> newRoute(String routePath) async {
    validateRoutePath(routePath);
    final generator = await _generatorBuilder(dartFrogNewBundle);
    final vars = <String, dynamic>{
      'route_path': routePath,

      /// todo: To add middleare jsut change this
      'type': 'route',
    };

    final routesDirectory = Directory(path.join(workingDirectory, 'routes'));

    if (!routesDirectory.existsSync()) {
      throw RouteValidationException(
        'No "routes" directory found in the give directory. ',
      );
    }

    await generator.hooks.preGen(
      vars: vars,
      workingDirectory: workingDirectory,
      onVarsChanged: vars.addAll,
      logger: logger,
    );

    if (!vars.containsKey('dir_path')) {
      throw RouteValidationException(
        'Failed to run generator.',
      );
    }

    final generateProgress = logger.progress('Creating route $routePath');

    await generator.generate(
      DirectoryGeneratorTarget(Directory(workingDirectory)),
      vars: vars,
    );

    await generator.hooks.postGen(
      vars: vars,
      workingDirectory: workingDirectory,
      logger: logger,
    );

    generateProgress.complete();

  }
}

class RouteValidationException implements Exception {
  RouteValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
