import 'dart:async';
import 'dart:io' as io;

import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

typedef ProcessRunner = Future<io.ProcessResult> Function(
  String executable,
  List<String> arguments, {
  String workingDirectory,
  bool runInShell,
});

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

Future<void> dartPubGet(
  HookContext context, {
  required String workingDirectory,
  required ProcessRunner runProcess,
  required void Function(int exitCode) exit,
}) async {
  final progress = context.logger.progress('Installing dependencies');
  try {
    final result = await runProcess(
      'dart',
      ['pub', 'get'],
      workingDirectory: workingDirectory,
      runInShell: true,
    );
    progress.complete();

    if (result.exitCode != 0) {
      context.logger.err('${result.stderr}');
      return exit(result.exitCode);
    }
  } on io.ProcessException catch (error) {
    context.logger.err(error.message);
    return exit(error.errorCode);
  }
}

const _asyncRunZoned = runZoned;

abstract class ExitOverrides {
  static final _token = Object();

  static ExitOverrides? get current {
    return Zone.current[_token] as ExitOverrides?;
  }

  static R runZoned<R>(R Function() body, {void Function(int)? exit}) {
    final overrides = _ExitOverridesScope(exit);
    return _asyncRunZoned(body, zoneValues: {_token: overrides});
  }

  void Function(int exitCode) get exit => io.exit;
}

class _ExitOverridesScope extends ExitOverrides {
  _ExitOverridesScope(this._exit);

  final ExitOverrides? _previous = ExitOverrides.current;
  final void Function(int exitCode)? _exit;

  @override
  void Function(int exitCode) get exit {
    return _exit ?? _previous?.exit ?? super.exit;
  }
}
