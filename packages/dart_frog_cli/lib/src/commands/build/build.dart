import 'dart:io';

import 'package:dart_frog_cli/src/command.dart';
import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason_logger/mason_logger.dart';

/// {@template build_command}
/// `dart_frog build` command which creates a production build`.
/// {@endtemplate}
class BuildCommand extends DartFrogCommand {
  /// {@macro build_command}
  BuildCommand({
    super.logger,
    void Function(Directory)? runtimeCompatibility,
  }) : _ensureRuntimeCompatibility =
            runtimeCompatibility ?? ensureRuntimeCompatibility {
    argParser.addOption(
      'dart-version',
      defaultsTo: 'stable',
      help: 'The Dart SDK version used to build the Dockerfile, defaults to'
          ' stable.',
    );
  }

  final void Function(Directory) _ensureRuntimeCompatibility;

  @override
  final String description = 'Create a production build.';

  @override
  final String name = 'build';

  @override
  Future<int> run() async {
    _ensureRuntimeCompatibility(cwd);

    final dartVersion = argResults!['dart-version'] as String;

    final prodServerBuilder = ProdServerBuilder(
      dartVersion: dartVersion,
      workingDirectory: cwd,
      logger: logger,
    );

    try {
      final exitCode = await prodServerBuilder.build();
      return exitCode.code;
    } catch (e) {
      logger.err(e.toString());
      return ExitCode.software.code;
    }
  }
}
