import 'package:dart_frog_cli/src/command.dart';
import 'package:dart_frog_cli/src/commands/build/templates/dart_frog_prod_server_bundle.dart';
import 'package:mason/mason.dart';

/// {@template build_command}
/// `dart_frog build` command which creates a production build`.
/// {@endtemplate}
class BuildCommand extends DartFrogCommand {
  /// {@macro build_command}
  BuildCommand({Logger? logger}) : super(logger: logger);

  @override
  final String description = 'Create a production build.';

  @override
  final String name = 'build';

  @override
  Future<int> run() async {
    final generator = await MasonGenerator.fromBundle(dartFrogProdServerBundle);
    var vars = <String, dynamic>{};

    await generator.hooks.preGen(
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
