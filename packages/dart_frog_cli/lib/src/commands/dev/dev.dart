import 'dart:io' as io;

import 'package:dart_frog_cli/src/command.dart';
import 'package:dart_frog_cli/src/commands/commands.dart';
import 'package:dart_frog_cli/src/commands/dev/templates/dart_frog_dev_server_bundle.dart';
import 'package:dart_frog_cli/src/dev_server_runner/dev_server_runner.dart';
import 'package:dart_frog_cli/src/runtime_compatibility.dart' as runtime_compat;
import 'package:mason/mason.dart';

/// Typedef for [DevServerRunner.new].
typedef DevServerRunnerBuilder = DevServerRunner Function({
  required Logger logger,
  required String port,
  required MasonGenerator devServerBundleGenerator,
  required String dartVmServicePort,
  required io.Directory workingDirectory,
});

/// {@template dev_command}
/// `dart_frog dev` command which starts the dev server`.
/// {@endtemplate}
class DevCommand extends DartFrogCommand {
  /// {@macro dev_command}
  DevCommand({
    super.logger,
    GeneratorBuilder? generator,
    DevServerRunnerBuilder? devServerRunnerBuilder,
    runtime_compat.RuntimeCompatibilityCallback? ensureRuntimeCompatibility,
  })  : _ensureRuntimeCompatibility = ensureRuntimeCompatibility ??
            runtime_compat.ensureRuntimeCompatibility,
        _generator = generator ?? MasonGenerator.fromBundle,
        _devServerRunnerBuilder =
            devServerRunnerBuilder ?? DevServerRunner.new {
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
  final runtime_compat.RuntimeCompatibilityCallback _ensureRuntimeCompatibility;

  @override
  final String description = 'Run a local development server.';

  @override
  final String name = 'dev';

  @override
  Future<int> run() async {
    _ensureRuntimeCompatibility(cwd);

    final port = io.Platform.environment['PORT'] ?? results['port'] as String;
    final dartVmServicePort = (results['dart-vm-service-port'] as String?) ??
        _defaultDartVmServicePort;
    final generator = await _generator(dartFrogDevServerBundle);

    final result = await _devServerRunnerBuilder(
      devServerBundleGenerator: generator,
      logger: logger,
      workingDirectory: cwd,
      port: port,
      dartVmServicePort: dartVmServicePort,
    ).start();

    return result.code;
  }
}
