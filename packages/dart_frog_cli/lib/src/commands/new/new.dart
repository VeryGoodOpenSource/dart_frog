import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dart_frog_cli/src/command.dart';
import 'package:dart_frog_cli/src/commands/commands.dart';
import 'package:dart_frog_cli/src/commands/new/templates/dart_frog_new_bundle.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

/// {@template new_command}
/// `dart_frog new <route|middleware> "path/to/route"`
///
/// Creates a new route or middleware for dart_frog.
/// {@endtemplate}
class NewCommand extends DartFrogCommand {
  /// {@macro new_command}
  NewCommand({
    super.logger,
    GeneratorBuilder? generator,
  }) : _generator = generator ?? MasonGenerator.fromBundle {
    addSubcommand(newRouteCommand = _NewSubCommand('route'));
    addSubcommand(newMiddlewareCommand = _NewSubCommand('middleware'));
  }

  final GeneratorBuilder _generator;

  @override
  String get description => 'Create a new route or middleware for dart_frog';

  @override
  String get name => 'new';

  @override
  final String invocation = 'dart_frog new <route|middleware> "path/to/route"';

  /// Subcommand for creating a new route.
  @visibleForTesting
  late final DartFrogCommand newRouteCommand;

  /// Subcommand for creating a new middleware.
  @visibleForTesting
  late final DartFrogCommand newMiddlewareCommand;
}

class _NewSubCommand extends DartFrogCommand {
  _NewSubCommand(this.name);

  @override
  String get description => 'Create a new $name for dart_frog';

  @override
  final String name;

  @override
  NewCommand get parent => super.parent! as NewCommand;

  @override
  late final String invocation = 'dart_frog new $name "path/to/route"';

  @visibleForTesting
  @override
  // ignore: invalid_use_of_visible_for_testing_member
  ArgResults? get testArgResults => parent.testArgResults;

  @override
  // ignore: invalid_use_of_visible_for_testing_member
  String? get testUsage => parent.testUsage;

  String get _routePath {
    final rest = results.rest;
    if (rest.isEmpty) {
      throw UsageException(
        'Provide a route path for the new $name',
        usageString,
      );
    }
    final routeName = rest.first;
    if (routeName.isEmpty) {
      throw UsageException(
        'Route path must not be empty',
        usageString,
      );
    }

    final segments =
        routeName.split('/').skipWhile((element) => element.isEmpty);

    for (final segment in segments) {
      if (segment.isEmpty) {
        throw UsageException(
          'Route path cannot contain empty segments',
          '',
        );
      }
      if (segment.contains(r'$')) {
        throw UsageException(
          'Route path cannot contain dollar signs',
          '',
        );
      }
      if (segment.contains(RegExp(r'[^a-zA-Z\d_\[\]]'))) {
        throw UsageException(
          'Route path segments must be valid Dart identifiers',
          '',
        );
      }
    }

    return routeName;
  }

  @override
  Future<int> run() async {
    final routePath = _routePath;

    final generator = await parent._generator(dartFrogNewBundle);

    final vars = <String, dynamic>{
      'route_path': routePath,
      'type': name,
    };

    final projectDirectory = _nearestDartFrogProject(cwd);
    if (projectDirectory == null) {
      throw UsageException(
        '''No dart_frog project found in the current directory or any of its parents. '''
        'Make sure to run this command within a dart_frog project.',
        usageString,
      );
    }

    final routesDirectory =
        Directory(path.join(projectDirectory.path, 'routes'));
    if (cwd.path != projectDirectory.path || cwd.path != routesDirectory.path) {
      final relativePath = path.relative(cwd.path, from: routesDirectory.path);
      vars['route_path'] = path.join(relativePath, routePath);
    }

    await generator.hooks.preGen(
      vars: vars,
      workingDirectory: projectDirectory.path,
      onVarsChanged: vars.addAll,
      logger: logger,
    );

    if (!vars.containsKey('dir_path')) {
      return ExitCode.software.code;
    }

    final generateProgress = logger.progress('Creating $name $routePath');

    await generator.generate(
      DirectoryGeneratorTarget(projectDirectory),
      vars: vars,
    );

    await generator.hooks.postGen(
      vars: vars,
      workingDirectory: projectDirectory.path,
      logger: logger,
    );
    generateProgress.complete();

    return ExitCode.success.code;
  }
}

/// Returns the nearest dart_frog project directory.
///
/// The directory with a DartFrog will be returned if it is found, otherwise
/// `null` will be returned.
Directory? _nearestDartFrogProject(Directory directory) {
  /// TODO(alestiago): Use a heuristic and only look into those directories
  /// that are parents of `/routes`.
  var currentDirectory = directory;
  while (path.split(currentDirectory.path).length > 1) {
    if (_isDartFrogProject(currentDirectory)) {
      return currentDirectory;
    } else {
      currentDirectory = currentDirectory.parent;
    }
  }
}

/// Returns whether the current directory is a dart_frog project.
///
/// A dart_frog project is defined as:
/// - A directory that contains a `pubspec.yaml` with a `dart_frog` dependency.
/// - A directory that containts a `routes` subdirectory.
bool _isDartFrogProject(Directory directory) {
  // TODO(alestiago): Actually parse the pubspec.yaml and check for the
  // dart_frog dependency.
  final routesDirectory = Directory(path.join(directory.path, 'routes'));
  final pubspecFile = File(path.join(directory.path, 'pubspec.yaml'));
  return directory.existsSync() &&
      routesDirectory.existsSync() &&
      pubspecFile.existsSync() &&
      pubspecFile.readAsStringSync().contains('dart_frog');
}
