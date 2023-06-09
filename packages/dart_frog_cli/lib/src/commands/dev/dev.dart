import 'dart:collection';
import 'dart:convert';
import 'dart:io' as io;

import 'package:dart_frog_cli/src/command.dart';
import 'package:dart_frog_cli/src/commands/commands.dart';
import 'package:dart_frog_cli/src/commands/dev/templates/dart_frog_dev_server_bundle.dart';
import 'package:dart_frog_cli/src/runtime_compatibility.dart'
    as runtime_compatibility;
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:stream_transform/stream_transform.dart';
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

/// Typedef for [RestorableDirectoryGeneratorTarget.new]
typedef RestorableDirectoryGeneratorTargetBuilder
    = RestorableDirectoryGeneratorTarget Function(Logger? logger);

/// Typedef for [io.exit].
typedef Exit = dynamic Function(int exitCode);

/// Regex for detecting warnings in the output of `dart run`.
final _warningRegex = RegExp(r'^.*:\d+:\d+: Warning: .*', multiLine: true);

/// Regex for detecting when the `dart_frog dev` fails to run for using a
/// Dart VM Service with an already used port.
///
/// Example:
/// ```sh
/// dart_frog dev # Runs the dev server, successfully using default ports
/// dart_frog dev --port=8085 # Fails to run the dev server
/// >>> Could not start the VM service: localhost:8181 is already in use.
/// ```
final _dartVmServiceAlreadyInUseErrorRegex = RegExp(
  '^Could not start the VM service: localhost:.* is already in use.',
  multiLine: true,
);

RestorableDirectoryGeneratorTarget _defaultGeneratorTarget(Logger? logger) {
  return RestorableDirectoryGeneratorTarget(
    io.Directory(
      path.join(io.Directory.current.path, '.dart_frog'),
    ),
    logger: logger,
  );
}

/// {@template dev_command}
/// `dart_frog dev` command which starts the dev server`.
/// {@endtemplate}
class DevCommand extends DartFrogCommand {
  /// {@macro dev_command}
  DevCommand({
    super.logger,
    void Function(io.Directory)? ensureRuntimeCompatibility,
    DirectoryWatcherBuilder? directoryWatcher,
    GeneratorBuilder? generator,
    RestorableDirectoryGeneratorTargetBuilder? generatorTarget,
    Exit? exit,
    bool? isWindows,
    io.ProcessSignal? sigint,
    ProcessStart? startProcess,
  })  : _ensureRuntimeCompatibility = ensureRuntimeCompatibility ??
            runtime_compatibility.ensureRuntimeCompatibility,
        _directoryWatcher = directoryWatcher ?? DirectoryWatcher.new,
        _generator = generator ?? MasonGenerator.fromBundle,
        _exit = exit ?? io.exit,
        _isWindows = isWindows ?? io.Platform.isWindows,
        _sigint = sigint ?? io.ProcessSignal.sigint,
        _startProcess = startProcess ?? io.Process.start,
        _generatorTarget = generatorTarget ?? _defaultGeneratorTarget {
    argParser
      ..addOption(
        'port',
        abbr: 'p',
        defaultsTo: '8080',
        help: 'Which port number the server should start on.',
      )
      ..addOption(
        'dart-vm-service-port',
        abbr: 'd',
        defaultsTo: _defaultDartVmServicePort,
        help: 'Which port number the dart vm service should listen on.',
      );
  }

  static const _defaultDartVmServicePort = '8181';

  final void Function(io.Directory) _ensureRuntimeCompatibility;
  final DirectoryWatcherBuilder _directoryWatcher;
  final GeneratorBuilder _generator;
  final Exit _exit;
  final bool _isWindows;

  /// Function used to start a process used for testing purposes only.
  @visibleForTesting
  ProcessRun? testRunProcess;

  ProcessRun get _runProcess => testRunProcess ?? io.Process.run;

  final io.ProcessSignal _sigint;
  final ProcessStart _startProcess;
  final RestorableDirectoryGeneratorTargetBuilder _generatorTarget;

  @override
  final String description = 'Run a local development server.';

  @override
  final String name = 'dev';

  @override
  Future<int> run() async {
    _ensureRuntimeCompatibility(cwd);

    var reloading = false;
    var hotReloadEnabled = false;
    final port = io.Platform.environment['PORT'] ?? results['port'] as String;
    final dartVmServicePort = (results['dart-vm-service-port'] as String?) ??
        _defaultDartVmServicePort;
    final target = _generatorTarget(logger);
    final generator = await _generator(dartFrogDevServerBundle);

    Future<void> codegen() async {
      logger.detail('[codegen] running pre-gen...');
      var vars = <String, dynamic>{'port': port};
      await generator.hooks.preGen(
        vars: vars,
        workingDirectory: cwd.path,
        onVarsChanged: (v) => vars = v,
      );

      logger.detail('[codegen] running generate...');
      final _ = await generator.generate(
        target,
        vars: vars,
        fileConflictResolution: FileConflictResolution.overwrite,
      );
      logger.detail('[codegen] complete.');
    }

    Future<void> reload() async {
      logger.detail('[codegen] reloading...');
      reloading = true;
      await codegen();
      reloading = false;
      logger.detail('[codegen] reload complete.');
    }

    final enableVmServiceFlag = '--enable-vm-service=$dartVmServicePort';

    Future<bool> serve() async {
      logger.detail(
        '''[process] dart $enableVmServiceFlag ${path.join('.dart_frog', 'server.dart')}''',
      );
      final process = await _startProcess(
        'dart',
        [enableVmServiceFlag, path.join('.dart_frog', 'server.dart')],
        runInShell: true,
      );

      // On Windows listen for CTRL-C and use taskkill to kill
      // the spawned process along with any child processes.
      // https://github.com/dart-lang/sdk/issues/22470
      if (_isWindows) _sigint.watch().listen((_) => _killProcess(process));

      var hasError = false;
      process.stderr.listen((_) async {
        hasError = true;

        if (reloading) return;

        final message = utf8.decode(_).trim();
        if (message.isEmpty) return;

        /// Suggest running `dart_frog ` if the error is a warning from
        final isDartVMServiceAlreadyInUseError =
            _dartVmServiceAlreadyInUseErrorRegex.hasMatch(message);

        if (isDartVMServiceAlreadyInUseError) {
          logger.err(
            '$message '
            '''Please, specify a different port using the `--dart-vm-service-port` argument when running `dart_frog dev`.''',
          );

          await _killProcess(process);
          logger.detail('[process] exit(1)');
          _exit(1);
        }

        /// Do not kill the process if the error is a warning from the SDK.
        final isSDKWarning = _warningRegex.hasMatch(message);

        if (isSDKWarning) {
          logger.warn(message);
        } else {
          logger.err(message);
        }

        if (!hotReloadEnabled && !isSDKWarning) {
          await _killProcess(process);
          logger.detail('[process] exit(1)');
          _exit(1);
        }

        await target.rollback();
      });

      process.stdout.listen((_) {
        final message = utf8.decode(_).trim();
        final containsHotReload = message.contains('[hotreload]');
        if (containsHotReload) hotReloadEnabled = true;
        if (message.isNotEmpty) logger.info(message);
        final shouldCacheSnapshot = containsHotReload && !hasError;
        if (shouldCacheSnapshot) target.cacheLatestSnapshot();
        hasError = false;
      });

      return hasError;
    }

    final progress = logger.progress('Serving');
    await codegen();
    final served = await serve();
    final localhost = link(uri: Uri.parse('http://localhost:$port'));
    if (served) {
      progress.complete('Running on $localhost');
    } else {
      progress.cancel();
    }

    final entrypoint = path.join(cwd.path, 'main.dart');
    final pubspec = path.join(cwd.path, 'pubspec.yaml');
    final public = path.join(cwd.path, 'public');
    final routes = path.join(cwd.path, 'routes');

    bool shouldReload(WatchEvent event) {
      logger.detail('[watcher] $event');
      return path.equals(entrypoint, event.path) ||
          path.equals(pubspec, event.path) ||
          path.isWithin(routes, event.path) ||
          path.isWithin(public, event.path);
    }

    final watcher = _directoryWatcher(path.join(cwd.path));
    final subscription = watcher.events
        .where(shouldReload)
        .debounce(Duration.zero)
        .listen((_) => reload());

    await subscription.asFuture<void>();
    await subscription.cancel();
    return ExitCode.success.code;
  }

  Future<void> _killProcess(io.Process process) async {
    logger.detail('[process] killing process...');
    if (_isWindows) {
      logger.detail('[process] taskkill /F /T /PID ${process.pid}');
      await _runProcess('taskkill', ['/F', '/T', '/PID', '${process.pid}']);
    } else {
      logger.detail('[process] process.kill()...');
      process.kill();
    }
    logger.detail('[process] killing process complete.');
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
  RestorableDirectoryGeneratorTarget(
    super.dir, {
    CreateFile? createFile,
    Logger? logger,
  })  : _cachedSnapshots = Queue<CachedFile>(),
        _createFile = createFile,
        _logger = logger;

  final CreateFile? _createFile;
  final Logger? _logger;
  final Queue<CachedFile> _cachedSnapshots;

  CachedFile? get _cachedSnapshot {
    return _cachedSnapshots.isNotEmpty ? _cachedSnapshots.last : null;
  }

  CachedFile? _latestSnapshot;

  /// Removes the latest cached snapshot.
  void _removeLatestSnapshot() {
    _logger?.detail('[codegen] attempting to remove latest snapshot.');
    if (_cachedSnapshots.length > 1) {
      _cachedSnapshots.removeLast();
      _logger?.detail('[codegen] removed latest snapshot.');
    }
  }

  /// Remove the latest snapshot and restore the previously
  /// cached snapshot.
  Future<void> rollback() async {
    _logger?.detail('[codegen] rolling back...');
    _removeLatestSnapshot();
    await _restoreLatestSnapshot();
    _logger?.detail('[codegen] rollback complete.');
  }

  /// Restore the latest cached snapshot.
  Future<void> _restoreLatestSnapshot() async {
    final snapshot = _cachedSnapshot;
    if (snapshot == null) return;
    _logger?.detail('[codegen] restoring previous snapshot...');
    await createFile(snapshot.path, snapshot.contents);
    _logger?.detail('[codegen] restored previous snapshot.');
  }

  /// Cache the latest recorded snapshot.
  void cacheLatestSnapshot() {
    final snapshot = _latestSnapshot;
    if (snapshot == null) return;
    _cachedSnapshots.add(snapshot);
    _logger?.detail('[codegen] cached latest snapshot.');
    // Keep only the 2 most recent snapshots.
    if (_cachedSnapshots.length > 2) _cachedSnapshots.removeFirst();
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
