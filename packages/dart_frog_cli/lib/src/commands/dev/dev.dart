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
      final process = await Process.start(
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

    final watcher = DirectoryWatcher(path.join(cwd.path, 'routes'));
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
