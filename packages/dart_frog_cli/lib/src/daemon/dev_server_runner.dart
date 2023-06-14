import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:mason/mason.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:watcher/watcher.dart';

import '../commands/commands.dart';
import '../commands/dev/templates/dart_frog_dev_server_bundle.dart';

/// Regex for detecting warnings in the output of `dart run`.
final _warningRegex = RegExp(r'^.*:\d+:\d+: Warning: .*', multiLine: true);

class DevServerRunner {
  DevServerRunner({
    required this.dartVmServicePort,
    required this.logger,
    String? port,
    RestorableDirectoryGeneratorTargetBuilder generatorTargetBuilder =
        _defaultGeneratorTarget,
    GeneratorBuilder generator = MasonGenerator.fromBundle,
    ProcessStart? startProcess,
    bool? isWindows,
    io.ProcessSignal? sigint,
  })  : port = port ?? '8080',
        _isWindows = isWindows ?? io.Platform.isWindows,
        _generatorBuilder = generator,
        _generatorTargetBuilder = generatorTargetBuilder,
        _sigint = sigint ?? io.ProcessSignal.sigint,
        _startProcess = startProcess ?? io.Process.start;

  bool isRunning = false;
  bool _isReloading = false;
  bool _hotReloadEnabled = false;

  final String port;
  final String? dartVmServicePort;
  final Logger logger;
  final RestorableDirectoryGeneratorTargetBuilder _generatorTargetBuilder;
  final GeneratorBuilder _generatorBuilder;
  final ProcessStart _startProcess;
  final bool _isWindows;
  final io.ProcessSignal _sigint;

  Future<MasonGenerator>? _generator;

  Future<MasonGenerator> get masonGenerator =>
      _generator ?? (() => _generatorBuilder(dartFrogDevServerBundle))();

  late final target = _generatorTargetBuilder(logger);

  /// parametrize this
  Directory get cwd => Directory.current;

  Future<void> codegen() async {
    logger.detail('[codegen] running pre-gen...');
    var vars = <String, dynamic>{'port': port};
    final generator = await masonGenerator;
    await generator.hooks.preGen(
      vars: vars,
      workingDirectory: io.Directory.current.path,
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

  Future<bool> reload() async {
    // if (isRunning) {
    //   return false;
    // }
    logger.detail('[codegen] reloading...');
    _isReloading = true;
    await codegen();
    _isReloading = false;
    logger.detail('[codegen] reload complete.');

    return true;
  }

  Future<void> run() async {
    isRunning = true;

    Future<void> serve() async {
      final enableVmServiceFlag = '--enable-vm-service'
          '${dartVmServicePort == null ? "" : "=$dartVmServicePort"}';

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

        if (_isReloading) return;

        final message = utf8.decode(_).trim();
        if (message.isEmpty) return;

        /// Do not kill the process if the error is a warning from the SDK.
        final isSDKWarning = _warningRegex.hasMatch(message);

        if (isSDKWarning) {
          logger.warn(message);
        } else {
          logger.err(message);
        }

        if (!_hotReloadEnabled && !isSDKWarning) {
          await _killProcess(process);
          logger.detail('[process] exit(1)');
          io.exit(1);
        }

        await target.rollback();
      });

      process.stdout.listen((_) {
        final message = utf8.decode(_).trim();
        final containsHotReload = message.contains('[hotreload]');
        if (containsHotReload) _hotReloadEnabled = true;
        if (message.isNotEmpty) logger.info(message);
        final shouldCacheSnapshot = containsHotReload && !hasError;
        if (shouldCacheSnapshot) target.cacheLatestSnapshot();
        hasError = false;
      });
    }

    final progress = logger.progress('Starting server on port $port');
    await codegen();
    await serve();
    final localhost = link(uri: Uri.parse('http://localhost:$port'));
    progress.complete('Running on $localhost');

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

    // todo: parametrize DirectoryWatcher.new
    final watcher = DirectoryWatcher(path.join(cwd.path));
    final subscription = watcher.events
        .where(shouldReload)
        .debounce(Duration.zero)
        .listen((_) => reload());

    unawaited(subscription.asFuture<void>().then((value) async {
      await subscription.cancel();
      _exitCodeCompleter.complete(ExitCode.success);
    }));
  }

  final Completer<ExitCode> _exitCodeCompleter = Completer<ExitCode>();

  Future<ExitCode> get exitCode => _exitCodeCompleter.future;

  Future<void> _killProcess(io.Process process) async {
    logger.detail('[process] killing process...');
    if (_isWindows) {
      logger.detail('[process] taskkill /F /T /PID ${process.pid}');
      await io.Process.run('taskkill', ['/F', '/T', '/PID', '${process.pid}']);
    } else {
      logger.detail('[process] process.kill()...');
      process.kill();
    }
    logger.detail('[process] killing process complete.');
  }
}

/// Typedef for [RestorableDirectoryGeneratorTarget.new]
typedef RestorableDirectoryGeneratorTargetBuilder
    = RestorableDirectoryGeneratorTarget Function(Logger? logger);

RestorableDirectoryGeneratorTarget _defaultGeneratorTarget(Logger? logger) {
  return RestorableDirectoryGeneratorTarget(
    io.Directory(
      path.join(io.Directory.current.path, '.dart_frog'),
    ),
    logger: logger,
  );
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
