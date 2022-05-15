import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dart_frog_cli/src/command.dart';
import 'package:dart_frog_cli/src/commands/create/templates/create_dart_frog_bundle.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

// A valid Dart identifier that can be used for a package, i.e. no
// capital letters.
// https://dart.dev/guides/language/language-tour#important-concepts
final RegExp _identifierRegExp = RegExp('[a-z_][a-z0-9_]*');

/// {@template create_command}
/// `dart_frog create` command which creates a new application.`.
/// {@endtemplate}
class CreateCommand extends DartFrogCommand {
  /// {@macro create_command}
  CreateCommand({super.logger}) {
    argParser.addOption(
      'project-name',
      help: 'The project name for this new project. '
          'This must be a valid dart package name.',
    );
  }

  @override
  final String description = 'Creates a new Dart Frog app.';

  @override
  final String name = 'create';

  @override
  Future<int> run() async {
    final outputDirectory = _outputDirectory;
    final projectName = _projectName;
    final generator = await MasonGenerator.fromBundle(createDartFrogBundle);
    final generateDone = logger.progress('Creating $projectName');
    final vars = <String, dynamic>{
      'name': projectName,
      'output_directory': outputDirectory.absolute.path
    };

    final _ = await generator.generate(
      DirectoryGeneratorTarget(outputDirectory),
      vars: vars,
    );
    generateDone();

    await generator.hooks.postGen(vars: vars, workingDirectory: cwd.path);

    return ExitCode.success.code;
  }

  /// Gets the project name.
  ///
  /// Uses the current directory path name
  /// if the `--project-name` option is not explicitly specified.
  String get _projectName {
    final projectName = results['project-name'] as String? ??
        path.basename(path.normalize(_outputDirectory.absolute.path));
    _validateProjectName(projectName);
    return projectName;
  }

  Directory get _outputDirectory {
    final rest = results.rest;
    _validateOutputDirectoryArg(rest);
    return Directory(rest.first);
  }

  void _validateOutputDirectoryArg(List<String> args) {
    if (args.isEmpty) {
      throw UsageException(
        'No option specified for the output directory.',
        usage,
      );
    }

    if (args.length > 1) {
      throw UsageException('Multiple output directories specified.', usage);
    }
  }

  void _validateProjectName(String name) {
    final isValidProjectName = _isValidPackageName(name);
    if (!isValidProjectName) {
      throw UsageException(
        '"$name" is not a valid package name.\n\n'
        'See https://dart.dev/tools/pub/pubspec#name for more information.',
        usage,
      );
    }
  }

  bool _isValidPackageName(String name) {
    final match = _identifierRegExp.matchAsPrefix(name);
    return match != null && match.end == name.length;
  }
}
