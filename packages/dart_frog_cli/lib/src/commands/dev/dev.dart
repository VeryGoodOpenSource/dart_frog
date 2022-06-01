import 'dart:convert';
import 'dart:io' as io;

import 'package:dart_frog_cli/src/command.dart';
import 'package:dart_frog_cli/src/commands/commands.dart';
import 'package:dart_frog_cli/src/commands/dev/templates/dart_frog_dev_server_bundle.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:watcher/watcher.dart';

/// Typedef for [io.Process.start].
typedef ProcessStart = Future<io.Process> Function(
  String executable,
  List<String> arguments, {
  bool runInShell,
});

/// Typedef for [io.Process.run].
typedef ProcessRun = Future<io.ProcessResult> Function(
  String executable,
  List<String> arguments,
);

/// Typedef for [DirectoryWatcher.new].
typedef DirectoryWatcherBuilder = DirectoryWatcher Function(
  String directory,
);

/// Typedef for [io.exit].
typedef Exit = dynamic Function(int exitCode);

/// {@template dev_command}
/// `dart_frog dev` command which starts the dev server`.
/// {@endtemplate}
class DevCommand extends DartFrogCommand {
  /// {@macro dev_command}
  DevCommand({
    super.logger,
    DirectoryWatcherBuilder? directoryWatcher,
    GeneratorBuilder? generator,
    Exit? exit,
    bool? isWindows,
    ProcessRun? runProcess,
    io.ProcessSignal? sigint,
    ProcessStart? startProcess,
  })  : _directoryWatcher = directoryWatcher ?? DirectoryWatcher.new,
        _generator = generator ?? MasonGenerator.fromBundle,
        _exit = exit ?? io.exit,
        _isWindows = isWindows ?? io.Platform.isWindows,
        _runProcess = runProcess ?? io.Process.run,
        _sigint = sigint ?? io.ProcessSignal.sigint,
        _startProcess = startProcess ?? io.Process.start;

  final DirectoryWatcherBuilder _directoryWatcher;
  final GeneratorBuilder _generator;
  final Exit _exit;
  final bool _isWindows;
  final ProcessRun _runProcess;
  final io.ProcessSignal _sigint;
  final ProcessStart _startProcess;

  @override
  final String description = 'Run a local development server.';

  @override
  final String name = 'dev';

  @override
  Future<int> run() async {
    final generator = await _generator(dartFrogDevServerBundle);

    Future<void> codegen() async {
      var vars = <String, dynamic>{};
      await generator.hooks.preGen(
        workingDirectory: cwd.path,
        onVarsChanged: (v) => vars = v,
      );

      final _ = await generator.generate(
        DirectoryGeneratorTarget(
          io.Directory(path.join(cwd.path, '.dart_frog')),
        ),
        vars: vars,
        fileConflictResolution: FileConflictResolution.overwrite,
      );
    }

    Future<void> serve() async {
      final process = await _startProcess(
        'dart',
        ['--enable-vm-service', path.join('.dart_frog', 'server.dart')],
        runInShell: true,
      );

      // On Windows listen for CTRL-C and use taskkill to kill
      // the spawned process along with any child processes.
      // https://github.com/dart-lang/sdk/issues/22470
      if (_isWindows) {
        _sigint.watch().listen((_) async {
          final result = await _runProcess(
            'taskkill',
            ['/F', '/T', '/PID', '${process.pid}'],
          );
          _exit(result.exitCode);
        });
      }

      process.stdout.listen((_) => logger.info(utf8.decode(_)));
      process.stderr.listen((_) => logger.err(utf8.decode(_)));
    }

    final progress = logger.progress('Serving');
    await codegen();
    await serve();
    progress.complete('Running on http://localhost:8080');

    final watcher = _directoryWatcher(path.join(cwd.path, 'routes'));
    final subscription = watcher.events.listen((event) async {
      final file = io.File(event.path);
      if (file.existsSync()) {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          await codegen();
        }
      }
    });

    await subscription.asFuture<void>();
    await subscription.cancel();
    return ExitCode.success.code;
  }
}
