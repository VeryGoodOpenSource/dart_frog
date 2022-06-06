import 'dart:io';

import 'package:dart_frog_cli/src/command.dart';
import 'package:dart_frog_cli/src/commands/build/templates/dart_frog_prod_server_bundle.dart';
import 'package:dart_frog_cli/src/commands/commands.dart';
import 'package:mason/mason.dart';

/// {@template build_command}
/// `dart_frog build` command which creates a production build`.
/// {@endtemplate}
class BuildCommand extends DartFrogCommand {
  /// {@macro build_command}
  BuildCommand({super.logger, GeneratorBuilder? generator})
      : _generator = generator ?? MasonGenerator.fromBundle {
    argParser.addOption(
      'port',
      abbr: 'p',
      defaultsTo: '8080',
      help: 'Which port number the server should start on.',
    );
  }

  final GeneratorBuilder _generator;

  @override
  final String description = 'Create a production build.';

  @override
  final String name = 'build';

  @override
  Future<int> run() async {
    final port = Platform.environment['PORT'] ?? results['port'] as String;
    final generator = await _generator(dartFrogProdServerBundle);
    var vars = <String, dynamic>{'port': port};

    await generator.hooks.preGen(
      vars: vars,
      workingDirectory: cwd.path,
      onVarsChanged: (v) => vars = v,
    );

    final _ = await generator.generate(
      DirectoryGeneratorTarget(cwd),
      vars: vars,
      fileConflictResolution: FileConflictResolution.overwrite,
    );

    await generator.hooks.postGen(workingDirectory: cwd.path);

    return ExitCode.success.code;
  }
}
