import 'dart:convert';
import 'dart:io' as io;

import 'package:dart_frog_cli/src/dev_server_runner/restorable_directory_generator_target.dart';
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

/// Typedef for [io.exit].
typedef Exit = dynamic Function(int exitCode);

/// Regex for detecting warnings in the output of `dart run`.
final _warningRegex = RegExp(r'^.*:\d+:\d+: Warning: .*', multiLine: true);

/// Regex for detecting when the `dart_frog dev` fails to run for using a
/// Dart VM Service with an already used port.
final _dartVmServiceAlreadyInUseErrorRegex = RegExp(
  '^Could not start the VM service: localhost:.* is already in use.',
  multiLine: true,
);

// TODO(renancaraujo): Add reload and stop methods.
/// {@template dev_server_runner}
/// A class that manages a local development server process lifecycle.
/// {@endtemplate}
class DevServerRunner {
  /// {@macro dev_server_runner}
  DevServerRunner({
    required this.logger,
    required this.port,
    required this.devServerBundleGenerator,
    required this.dartVmServicePort,
    required this.workingDirectory,
    @visibleForTesting DirectoryWatcherBuilder? directoryWatcher,
    @visibleForTesting
    RestorableDirectoryGeneratorTargetBuilder? generatorTarget,
    @visibleForTesting bool? isWindows,
    @visibleForTesting io.ProcessSignal? sigint,
    @visibleForTesting ProcessStart? startProcess,
    @visibleForTesting ProcessRun? runProcess,
    @visibleForTesting Exit? exit,
  })  : _directoryWatcher = directoryWatcher ?? DirectoryWatcher.new,
        _exit = exit ?? io.exit,
        _isWindows = isWindows ?? io.Platform.isWindows,
        _sigint = sigint ?? io.ProcessSignal.sigint,
        _startProcess = startProcess ?? io.Process.start,
        _runProcess = runProcess ?? io.Process.run,
        _generatorTarget =
            generatorTarget ?? RestorableDirectoryGeneratorTarget.new,
        assert(port.isNotEmpty, 'port cannot be empty'),
        assert(
          dartVmServicePort.isNotEmpty,
          'dartVmServicePort cannot be empty',
        );

  /// [Logger] instance used to wrap stdout.
  final Logger logger;

  /// Which port number the server should start on.
  final String port;

  /// Which port number the dart vm service should listen on.
  final String dartVmServicePort;

  /// The [MasonGenerator] used to generate the dev server runtime code.
  final MasonGenerator devServerBundleGenerator;

  /// The working directory of the dart_frog project.
  final io.Directory workingDirectory;

  final DirectoryWatcherBuilder _directoryWatcher;
  final ProcessStart _startProcess;
  final ProcessRun _runProcess;
  final RestorableDirectoryGeneratorTargetBuilder _generatorTarget;
  final Exit _exit;
  final bool _isWindows;

  final io.ProcessSignal _sigint;
  late final _target = _generatorTarget(
    io.Directory(path.join(workingDirectory.path, '.dart_frog')),
    logger: logger,
  );

  var _isReloading = false;

  Future<void> _codegen() async {
    logger.detail('[codegen] running pre-gen...');
    var vars = <String, dynamic>{'port': port};
    await devServerBundleGenerator.hooks.preGen(
      vars: vars,
      workingDirectory: workingDirectory.path,
      onVarsChanged: (v) => vars = v,
    );

    logger.detail('[codegen] running generate...');
    final _ = await devServerBundleGenerator.generate(
      _target,
      vars: vars,
      fileConflictResolution: FileConflictResolution.overwrite,
    );
    logger.detail('[codegen] complete.');
  }

  Future<void> _reload() async {
    logger.detail('[codegen] reloading...');
    _isReloading = true;
    await _codegen();
    _isReloading = false;
    logger.detail('[codegen] reload complete.');
  }

  Future<void> _killProcess(io.Process process) async {
    _isReloading = false;
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

  // TODO(renancaraujo): this method returns a future that completes when the
  // process is killed, but it should return a future that completes when the
  // process is finished starting.
  /// Starts the development server.
  Future<ExitCode> start() async {
    var isHotReloadingEnabled = false;

    Future<void> serve() async {
      final enableVmServiceFlag = '--enable-vm-service=$dartVmServicePort';

      logger.detail(
        '''[process] dart $enableVmServiceFlag --enable-asserts ${path.join('.dart_frog', 'server.dart')}''',
      );

      final process = await _startProcess(
        'dart',
        [
          enableVmServiceFlag,
          '--enable-asserts',
          path.join('.dart_frog', 'server.dart')
        ],
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

        final isDartVMServiceAlreadyInUseError =
            _dartVmServiceAlreadyInUseErrorRegex.hasMatch(message);
        final isSDKWarning = _warningRegex.hasMatch(message);

        if (isDartVMServiceAlreadyInUseError) {
          logger.err(
            '$message '
            '''Try specifying a different port using the `--dart-vm-service-port` argument when running `dart_frog dev`.''',
          );
        } else if (isSDKWarning) {
          // Do not kill the process if the error is a warning from the SDK.
          logger.warn(message);
        } else {
          logger.err(message);
        }

        if ((!isHotReloadingEnabled && !isSDKWarning) ||
            isDartVMServiceAlreadyInUseError) {
          await _killProcess(process);
          logger.detail('[process] exit(1)');
          _exit(1);
        }

        await _target.rollback();
      });

      process.stdout.listen((_) {
        final message = utf8.decode(_).trim();
        final containsHotReload = message.contains('[hotreload]');
        if (containsHotReload) isHotReloadingEnabled = true;
        if (message.isNotEmpty) logger.info(message);
        final shouldCacheSnapshot = containsHotReload && !hasError;
        if (shouldCacheSnapshot) _target.cacheLatestSnapshot();
        hasError = false;
      });
    }

    final progress = logger.progress('Serving');
    await _codegen();
    await serve();

    final localhost = link(uri: Uri.parse('http://localhost:$port'));
    progress.complete('Running on $localhost');

    final cwdPath = workingDirectory.path;
    final entrypoint = path.join(cwdPath, 'main.dart');
    final pubspec = path.join(cwdPath, 'pubspec.yaml');
    final public = path.join(cwdPath, 'public');
    final routes = path.join(cwdPath, 'routes');

    bool shouldReload(WatchEvent event) {
      logger.detail('[watcher] $event');
      return path.equals(entrypoint, event.path) ||
          path.equals(pubspec, event.path) ||
          path.isWithin(routes, event.path) ||
          path.isWithin(public, event.path);
    }

    final watcher = _directoryWatcher(path.join(cwdPath));
    final subscription = watcher.events
        .where(shouldReload)
        .debounce(Duration.zero)
        .listen((_) => _reload());

    await subscription.asFuture<void>();
    await subscription.cancel();
    return ExitCode.success;
  }
}
