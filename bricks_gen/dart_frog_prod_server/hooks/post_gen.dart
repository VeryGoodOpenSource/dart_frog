import 'dart:async';
import 'dart:io' as io;

import 'package:mason/mason.dart' show HookContext, lightCyan;
import 'package:path/path.dart' as path;

import 'src/dart_pub_get.dart';
import 'src/exit_overrides.dart';

void _defaultExit(int code) => ExitOverrides.current?.exit ?? io.exit;

Future<void> run(HookContext context) => postGen(context);

Future<void> postGen(
  HookContext context, {
  io.Directory? directory,
  ProcessRunner runProcess = io.Process.run,
  void Function(int exitCode) exit = _defaultExit,
}) async {
  final projectDirectory = directory ?? io.Directory.current;
  final buildDirectoryPath = path.join(projectDirectory.path, 'build');

  await dartPubGet(
    context,
    workingDirectory: buildDirectoryPath,
    runProcess: runProcess,
    exit: exit,
  );

  final relativeBuildPath = path.relative(buildDirectoryPath);
  context.logger
    ..info('')
    ..success('Created a production build!')
    ..info('')
    ..info('Start the production server by running:')
    ..info('')
    ..info(
      '''${lightCyan.wrap('dart ${path.join(relativeBuildPath, 'bin', 'server.dart')}')}''',
    );
}
