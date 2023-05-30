import 'dart:io';

import 'package:dart_frog_cli/src/command.dart';
import 'package:dart_frog_cli/src/commands/build/templates/dart_frog_prod_server_bundle.dart';
import 'package:dart_frog_cli/src/commands/commands.dart';
import 'package:dart_frog_cli/src/runtime_compatibility.dart'
    as runtime_compatibility;
import 'package:mason/mason.dart';

/// {@template build_command}
/// `dart_frog build` command which creates a production build`.
/// {@endtemplate}
class BuildCommand extends DartFrogCommand {
  /// {@macro build_command}
  BuildCommand({
    super.logger,
    void Function(Directory)? ensureRuntimeCompatibility,
    GeneratorBuilder? generator,
  })  : _ensureRuntimeCompatibility = ensureRuntimeCompatibility ??
            runtime_compatibility.ensureRuntimeCompatibility,
        _generator = generator ?? MasonGenerator.fromBundle {
    argParser.addOption(
      'dart-version',
      defaultsTo: 'stable',
      help: 'The Dart SDK version used to build the Dockerfile, defaulst to'
          ' stable.',
    );
  }

  final void Function(Directory) _ensureRuntimeCompatibility;
  final GeneratorBuilder _generator;

  @override
  final String description = 'Create a production build.';

  @override
  final String name = 'build';

  @override
  Future<int> run() async {
    _ensureRuntimeCompatibility(cwd);

    final generator = await _generator(dartFrogProdServerBundle);
    var vars = <String, dynamic>{
      'dartVersion': results['dart-version'],
    };

    logger.detail('[codegen] running pre-gen...');
    await generator.hooks.preGen(
      vars: vars,
      workingDirectory: cwd.path,
      onVarsChanged: (v) => vars = v,
    );

    logger.detail('[codegen] running generate...');
    final _ = await generator.generate(
      DirectoryGeneratorTarget(cwd),
      vars: vars,
      fileConflictResolution: FileConflictResolution.overwrite,
    );

    logger.detail('[codegen] running post-gen...');
    await generator.hooks.postGen(workingDirectory: cwd.path);

    logger.detail('[codegen] complete.');
    return ExitCode.success.code;
  }
}
