import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dart_frog_cli/src/command.dart';
import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason/mason.dart';

/// Definition for a function that builds a [RouteConfiguration] from a
/// [Directory].
typedef RouteConfigurationBuilder = RouteConfiguration Function(
  Directory directory,
);

/// {@template list_command}
/// `dart_frog list "path/to/project"`
///
/// Lists the routes on the project.
/// {@endtemplate}
class ListCommand extends DartFrogCommand {
  /// {@macro list_command}
  ListCommand({
    super.logger,
    RouteConfigurationBuilder buildConfiguration = buildRouteConfiguration,
  }) : _buildConfiguration = buildConfiguration;

  final RouteConfigurationBuilder _buildConfiguration;

  @override
  String get description => 'Lists the routes on a Dart Frog project.';

  @override
  String get name => 'list';

  @override
  final String invocation = 'dart_frog list "path/to/project"';

  @override
  Future<int> run() async {
    final projectDir = _projectDirectory;

    final configuration = _buildConfiguration(projectDir);

    logger
      ..info('Route list 🐸:')
      ..info('==============\n');

    for (final endpoint in configuration.endpoints.keys) {
      logger.info(endpoint);
    }

    return ExitCode.success.code;
  }

  Directory get _projectDirectory {
    final rest = results.rest;
    _validateProjectDirectoryArg(rest);
    return Directory(rest.first);
  }

  void _validateProjectDirectoryArg(List<String> args) {
    if (args.isEmpty) {
      throw UsageException(
        'No project directory specified.',
        usageString,
      );
    }

    if (args.length > 1) {
      throw UsageException(
        'Multiple project directories specified.',
        usageString,
      );
    }
  }
}
