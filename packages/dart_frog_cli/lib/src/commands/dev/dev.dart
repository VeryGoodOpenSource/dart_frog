import 'dart:convert';
import 'dart:io';

import 'package:dart_frog_cli/src/command.dart';
import 'package:dart_frog_cli/src/commands/commands.dart';
import 'package:dart_frog_cli/src/commands/dev/templates/dart_frog_dev_server_bundle.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:watcher/watcher.dart';

/// Typedef for [Process.start].
typedef ProcessStart = Future<Process> Function(
  String executable,
  List<String> arguments, {
  bool runInShell,
});

/// Typedef for [DirectoryWatcher.new].
typedef DirectoryWatcherBuilder = DirectoryWatcher Function(
  String directory,
);

/// {@template dev_command}
/// `dart_frog dev` command which starts the dev server`.
/// {@endtemplate}
class DevCommand extends DartFrogCommand {
  /// {@macro dev_command}
  DevCommand({
    super.logger,
    DirectoryWatcherBuilder? directoryWatcher,
    GeneratorBuilder? generator,
    ProcessStart? startProcess,
  })  : _directoryWatcher = directoryWatcher ?? DirectoryWatcher.new,
        _generator = generator ?? MasonGenerator.fromBundle,
        _startProcess = startProcess ?? Process.start;

  final GeneratorBuilder _generator;
  final ProcessStart _startProcess;
  final DirectoryWatcherBuilder _directoryWatcher;

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
        DirectoryGeneratorTarget(Directory(path.join(cwd.path, '.dart_frog'))),
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

      process.stdout.listen((_) => logger.info(utf8.decode(_)));
      process.stderr.listen((_) => logger.err(utf8.decode(_)));
    }

    final done = logger.progress('Serving');
    await codegen();
    await serve();
    done('Running on http://localhost:8080');

    final watcher = _directoryWatcher(path.join(cwd.path, 'routes'));
    final subscription = watcher.events.listen((event) async {
      final file = File(event.path);
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
