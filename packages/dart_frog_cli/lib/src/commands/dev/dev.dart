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

RestorableDirectoryGeneratorTarget get _defaultGeneratorTarget {
  return RestorableDirectoryGeneratorTarget(
    io.Directory(
      path.join(io.Directory.current.path, '.dart_frog'),
    ),
  );
}

/// {@template dev_command}
/// `dart_frog dev` command which starts the dev server`.
/// {@endtemplate}
class DevCommand extends DartFrogCommand {
  /// {@macro dev_command}
  DevCommand({
    super.logger,
    DirectoryWatcherBuilder? directoryWatcher,
    GeneratorBuilder? generator,
    RestorableDirectoryGeneratorTarget? generatorTarget,
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
        _startProcess = startProcess ?? io.Process.start,
        _generatorTarget = generatorTarget ?? _defaultGeneratorTarget {
    argParser.addOption(
      'port',
      abbr: 'p',
      defaultsTo: '8080',
      help: 'Which port number the server should start on.',
    );
  }

  final DirectoryWatcherBuilder _directoryWatcher;
  final GeneratorBuilder _generator;
  final Exit _exit;
  final bool _isWindows;
  final ProcessRun _runProcess;
  final io.ProcessSignal _sigint;
  final ProcessStart _startProcess;
  final RestorableDirectoryGeneratorTarget _generatorTarget;

  @override
  final String description = 'Run a local development server.';

  @override
  final String name = 'dev';

  @override
  Future<int> run() async {
    var hotReloadEnabled = false;
    final port = io.Platform.environment['PORT'] ?? results['port'] as String;
    final generator = await _generator(dartFrogDevServerBundle);

    Future<void> codegen() async {
      var vars = <String, dynamic>{'port': port};
      await generator.hooks.preGen(
        vars: vars,
        workingDirectory: cwd.path,
        onVarsChanged: (v) => vars = v,
      );

      final _ = await generator.generate(
        _generatorTarget,
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
      if (_isWindows) _sigint.watch().listen((_) => _killProcess(process));

      var hasError = false;
      process.stderr.listen((_) async {
        hasError = true;
        logger.err(utf8.decode(_));

        if (!hotReloadEnabled) {
          await _killProcess(process);
          _exit(1);
        }

        await _generatorTarget.restore();
      });

      process.stdout.listen((_) {
        final message = utf8.decode(_).trim();
        if (message.contains('[hotreload]')) hotReloadEnabled = true;
        if (!hasError) _generatorTarget.cacheLatestSnapshot();
        if (message.isNotEmpty) logger.info(message);
        hasError = false;
      });
    }

    final progress = logger.progress('Serving');
    await codegen();
    await serve();
    progress.complete('Running on http://localhost:$port');

    final public = path.join(cwd.path, 'public');
    final routes = path.join(cwd.path, 'routes');

    bool shouldRunCodegen(WatchEvent event) {
      return path.isWithin(routes, event.path) ||
          path.isWithin(public, event.path);
    }

    final watcher = _directoryWatcher(path.join(cwd.path));
    final subscription =
        watcher.events.where(shouldRunCodegen).listen((_) => codegen());

    await subscription.asFuture<void>();
    await subscription.cancel();
    return ExitCode.success.code;
  }

  Future<void> _killProcess(io.Process process) async {
    if (_isWindows) {
      final result = await _runProcess(
        'taskkill',
        ['/F', '/T', '/PID', '${process.pid}'],
      );
      return _exit(result.exitCode);
    }
    process.kill();
  }
}

/// {@template cached_file}
/// A cached file which consists of the file path and contents.
/// {@endtemplate}
class CachedFile {
  /// {@macro cached_file}
  const CachedFile({required this.path, required this.contents});

  /// The generated file path.
  final String path;

  /// The contents of the generated file.s
  final List<int> contents;
}

/// Signature for the `createFile` method on [DirectoryGeneratorTarget].
typedef CreateFile = Future<GeneratedFile> Function(
  String path,
  List<int> contents, {
  Logger? logger,
  OverwriteRule? overwriteRule,
});

/// {@template restorable_directory_generator_target}
/// A [DirectoryGeneratorTarget] that is capable of
/// caching and restoring file snapshots.
/// {@endtemplate}
class RestorableDirectoryGeneratorTarget extends DirectoryGeneratorTarget {
  /// {@macro restorable_directory_generator_target}
  RestorableDirectoryGeneratorTarget(super.dir, {CreateFile? createFile})
      : _createFile = createFile;

  final CreateFile? _createFile;
  CachedFile? _cachedSnapshot;
  CachedFile? _latestSnapshot;

  /// Restore the latest cached snapshot.
  Future<void> restore() async {
    final snapshot = _cachedSnapshot;
    if (snapshot == null) return;
    await createFile(snapshot.path, snapshot.contents);
  }

  /// Cache the latest recorded snapshot.
  void cacheLatestSnapshot() {
    final snapshot = _latestSnapshot;
    if (snapshot == null) return;
    _cachedSnapshot = snapshot;
  }

  @override
  Future<GeneratedFile> createFile(
    String path,
    List<int> contents, {
    Logger? logger,
    OverwriteRule? overwriteRule,
  }) {
    _latestSnapshot = CachedFile(path: path, contents: contents);
    return (_createFile ?? super.createFile)(
      path,
      contents,
      logger: logger,
      overwriteRule: overwriteRule,
    );
  }
}
