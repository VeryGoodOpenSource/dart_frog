import 'dart:io';

import 'package:dart_frog_cli/src/commands/commands.dart';
import 'package:dart_frog_cli/src/commands/dev/templates/dart_frog_dev_server_bundle.dart';
import 'package:dart_frog_cli/src/daemon/daemon.dart';
import 'package:dart_frog_cli/src/dev_server_runner/dev_server_runner.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';

/// {@template dev_server_domain}
/// A [DomainBase] which includes operations for starting and stopping
/// [DevServerRunner]s.
/// {@endtemplate}
class DevServerDomain extends DomainBase {
  /// {@macro dev_server_domain}
  DevServerDomain(
    super.daemon, {
    @visibleForTesting super.getId,
    @visibleForTesting GeneratorBuilder? generator,
    @visibleForTesting DevServerRunnerBuilder? devServerRunnerBuilder,
  })  : _generator = generator ?? MasonGenerator.fromBundle,
        _devServerRunnerBuilder =
            devServerRunnerBuilder ?? DevServerRunner.new {
    addHandler('start', _start);
    addHandler('reload', _reload);
    addHandler('stop', _stop);
  }

  @override
  String get domainName => 'dev_server';

  final _devServerRunners = <String, DevServerRunner>{};

  final GeneratorBuilder _generator;
  final DevServerRunnerBuilder _devServerRunnerBuilder;

  /// Starts a [DevServerRunner] for the given [request].
  Future<DaemonResponse> _start(DaemonRequest request) async {
    final workingDirectory = request.params?['workingDirectory'];
    if (workingDirectory is! String) {
      throw const DartFrogDaemonMalformedMessageException(
        'invalid workingDirectory',
      );
    }

    final port = request.params?['port'];
    if (port is! int) {
      throw const DartFrogDaemonMalformedMessageException('invalid port');
    }

    final dartVmServicePort = request.params?['dartVmServicePort'];
    if (dartVmServicePort is! int) {
      throw const DartFrogDaemonMalformedMessageException(
        'invalid dartVmServicePort',
      );
    }

    final applicationId = getId();

    daemon.sendEvent(
      DaemonEvent(
        domain: domainName,
        event: 'applicationStarting',
        params: {
          'applicationId': applicationId,
          'requestId': request.id,
        },
      ),
    );

    final devServerBundleGenerator = await _generator(dartFrogDevServerBundle);

    final logger = DaemonLogger(
      domain: domainName,
      params: {
        'applicationId': applicationId,
        'requestId': request.id,
        'workingDirectory': workingDirectory,
      },
      sendEvent: daemon.sendEvent,
      idGenerator: getId,
    );

    final devServerRunner = _devServerRunnerBuilder(
      logger: logger,
      port: '$port',
      devServerBundleGenerator: devServerBundleGenerator,
      dartVmServicePort: '$dartVmServicePort',
      workingDirectory: Directory(workingDirectory),
    );

    _devServerRunners[applicationId] = devServerRunner;

    try {
      await devServerRunner.start();

      devServerRunner.exitCode.then((exitCode) {
        daemon.sendEvent(
          DaemonEvent(
            domain: domainName,
            event: 'applicationExit',
            params: {
              'applicationId': applicationId,
              'requestId': request.id,
              'workingDirectory': workingDirectory,
              'exitCode': exitCode.code,
            },
          ),
        );
      }).ignore();

      return DaemonResponse.success(
        id: request.id,
        result: {
          'applicationId': applicationId,
        },
      );
    } catch (e) {
      return DaemonResponse.error(
        id: request.id,
        error: {
          'applicationId': applicationId,
          'message': e.toString(),
        },
      );
    }
  }

  Future<DaemonResponse> _reload(DaemonRequest request) async {
    final applicationId = request.params?['applicationId'];
    if (applicationId is! String) {
      throw const DartFrogDaemonMalformedMessageException(
        'invalid applicationId',
      );
    }

    final runner = _devServerRunners[applicationId];
    if (runner == null) {
      return DaemonResponse.error(
        id: request.id,
        error: {
          'applicationId': applicationId,
          'message': 'Application not found',
        },
      );
    }

    try {
      await runner.reload();

      return DaemonResponse.success(
        id: request.id,
        result: {
          'applicationId': applicationId,
        },
      );
    } catch (e) {
      return DaemonResponse.error(
        id: request.id,
        error: {
          'applicationId': applicationId,
          'message': e.toString(),
        },
      );
    }
  }

  Future<DaemonResponse> _stop(DaemonRequest request) async {
    final applicationId = request.params?['applicationId'];
    if (applicationId is! String) {
      throw const DartFrogDaemonMalformedMessageException(
        'invalid applicationId',
      );
    }

    final runner = _devServerRunners.remove(applicationId);
    if (runner == null) {
      return DaemonResponse.error(
        id: request.id,
        error: {
          'applicationId': applicationId,
          'message': 'Application not found',
        },
      );
    }

    try {
      await runner.stop();

      _devServerRunners.remove(applicationId);

      final exitCode = await runner.exitCode;

      return DaemonResponse.success(
        id: request.id,
        result: {
          'applicationId': applicationId,
          'exitCode': exitCode.code,
        },
      );
    } catch (e) {
      if (!runner.isCompleted) {
        _devServerRunners[applicationId] = runner;
      }
      return DaemonResponse.error(
        id: request.id,
        error: {
          'applicationId': applicationId,
          'message': e.toString(),
        },
      );
    }
  }

  @override
  Future<void> dispose() async {
    for (final runner in _devServerRunners.values) {
      await runner.stop();
    }
    _devServerRunners.clear();
  }
}
