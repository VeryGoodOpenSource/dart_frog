import 'dart:async';
import 'dart:io' as io;

import 'package:dart_frog_cli/src/command.dart';
import 'package:dart_frog_cli/src/commands/commands.dart';
import 'package:dart_frog_cli/src/commands/dev/templates/dart_frog_dev_server_bundle.dart';
import 'package:dart_frog_cli/src/dev_server_runner/dev_server_runner.dart';
import 'package:dart_frog_cli/src/runtime_compatibility.dart'
    as runtime_compatibility;
import 'package:mason/mason.dart';

/// {@template dev_command}
/// `dart_frog dev` command which starts the dev server`.
/// {@endtemplate}
class DevCommand extends DartFrogCommand {
  /// {@macro dev_command}
  DevCommand({
    super.logger,
    GeneratorBuilder? generator,
    DevServerRunnerBuilder? devServerRunnerBuilder,
    runtime_compatibility.RuntimeCompatibilityCallback?
        ensureRuntimeCompatibility,
    io.Stdin? stdin,
  })  : _ensureRuntimeCompatibility = ensureRuntimeCompatibility ??
            runtime_compatibility.ensureRuntimeCompatibility,
        _generator = generator ?? MasonGenerator.fromBundle,
        _devServerRunnerBuilder = devServerRunnerBuilder ?? DevServerRunner.new,
        _stdin = stdin ?? io.stdin {
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

  final GeneratorBuilder _generator;
  final DevServerRunnerBuilder _devServerRunnerBuilder;
  final runtime_compatibility.RuntimeCompatibilityCallback
      _ensureRuntimeCompatibility;
  final io.Stdin _stdin;

  @override
  final String description = 'Run a local development server.';

  @override
  final String name = 'dev';

  StreamSubscription<List<int>>? _stdinSubscription;

  late final DevServerRunner _devServerRunner;

  void _startListeningForHelpers() {
    if (_stdinSubscription != null) return;

    // listen for the R key
    if (_stdin.hasTerminal) {
      _stdin
        ..echoMode = false
        ..lineMode = false;
    }
    _stdinSubscription = _stdin.listen((event) {
      if (event.length == 1 && event.first == 82) {
        _devServerRunner.reload();
      }
    });
    logger.info('Press R to reload the page');
  }

  void _stopListeningForHelpers() {
    _stdinSubscription?.cancel();
    _stdinSubscription = null;

    if (_stdin.hasTerminal) {
      _stdin
        ..lineMode = true
        ..echoMode = true;
    }
  }

  @override
  Future<int> run() async {
    _ensureRuntimeCompatibility(cwd);

    final port = io.Platform.environment['PORT'] ?? results['port'] as String;
    final dartVmServicePort = (results['dart-vm-service-port'] as String?) ??
        _defaultDartVmServicePort;
    final generator = await _generator(dartFrogDevServerBundle);

    _devServerRunner = _devServerRunnerBuilder(
      devServerBundleGenerator: generator,
      logger: logger,
      workingDirectory: cwd,
      port: port,
      dartVmServicePort: dartVmServicePort,
      onHotReloadEnabled: _startListeningForHelpers,
    );

    try {
      await _devServerRunner.start();
    } on DartFrogDevServerException catch (e) {
      logger.err(e.message);
      return ExitCode.software.code;
    }

    final result = await _devServerRunner.exitCode;

    _stopListeningForHelpers();

    return result.code;
  }
}
