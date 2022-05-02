import 'dart:convert';
import 'dart:io';

import 'package:dart_frog_cli/src/command.dart';
import 'package:dart_frog_cli/src/commands/dev/templates/dart_frog_server_bundle.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:watcher/watcher.dart';

/// {@template dev_command}
/// `dart_frog dev` command which starts the dev server`.
/// {@endtemplate}
class DevCommand extends DartFrogCommand {
  /// {@macro dev_command}
  DevCommand({Logger? logger}) : super(logger: logger);

  @override
  final String description = 'Starts the dev server';

  @override
  final String name = 'dev';

  @override
  Future<int> run() async {
    final generator = await MasonGenerator.fromBundle(dartFrogServerBundle);
    Process? process;

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
      process?.kill();
      await Process.run('pkill', ['-f', '.dart_frog/server.dart']);
      await process?.exitCode;
      process = await Process.start(
        'dart',
        [path.join('.dart_frog', 'server.dart')],
        runInShell: true,
      );

      process?.stdout.listen((_) => logger.info(utf8.decode(_)));
    }

    Future<void> start({bool restart = false}) async {
      final done = logger.progress(restart ? 'Reloading' : 'Serving');
      await codegen();
      await serve();
      done();

      if (!restart) {
        logger.alert('Running at ${InternetAddress.anyIPv4.address}:8080');
      }
    }

    await start();

    final watcher = DirectoryWatcher(path.join(cwd.path, 'routes'));
    final subscription = watcher.events.listen((_) {
      start(restart: true);
    });

    await subscription.asFuture<void>();
    await subscription.cancel();
    return ExitCode.success.code;
  }
}
