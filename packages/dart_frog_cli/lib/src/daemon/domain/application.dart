import 'dart:async';

import 'package:dart_frog_cli/src/daemon/dev_server_runner.dart';
import 'package:dart_frog_cli/src/daemon/domain/domain.dart';
import 'package:dart_frog_cli/src/daemon/logger.dart';
import 'package:dart_frog_cli/src/daemon/protocol.dart';
import 'package:mason/mason.dart';

class ApplicationDomain extends Domain {
  ApplicationDomain(super.daemon) {
    addHandler('start', start);
    addHandler('reload', reload);
  }

  @override
  String get name => 'application';

  Map<String, ApplicationInstance> _instances = {};

  Future<DaemonResponse> start(DaemonRequest request) async {
    final port = request.params['port'] as String?;
    final dartVmServicePort = request.params['dartVmServicePort'] as String?;
    final workingDirectory = request.params['workingDirectory'] as String;

    final applicationId = getId();

    final Logger logger = DaemonLogger(this, {
      'applicationId': applicationId,
      'workingDirectory': workingDirectory,
    });

    final instance = _instances[applicationId] = ApplicationInstance(
      DevServerRunner(
          port: port,
          dartVmServicePort: dartVmServicePort,
          logger: logger,
          workingDirectory: workingDirectory),
      applicationId,
    );

    try {
      await instance.runner.run();

      unawaited(instance.runner.exitCode.then((exitCode) {
        daemon.send(
          DaemonEvent(
            domain: name,
            event: 'applicationExit',
            params: {
              'applicationId': applicationId,
              'exitCode': exitCode.code,
            },
          ),
        );
      }));

      return DaemonResponse.success(id: request.id, result: {
        'applicationId': applicationId,
      });
    } catch (e) {
      // todo: deal with runner going kaboom
      return DaemonResponse.error(id: request.id, error: {
        'applicationId': applicationId,
        'message': e.toString(),
      });
    }
  }

  Future<DaemonResponse> reload(DaemonRequest request) async {
    // todo: handle malformed params
    final applicationId = request.params['applicationId'] as String;
    final instance = _instances[applicationId];
    if (instance == null) {
      return DaemonResponse.error(id: request.id, error: {
        'applicationId': applicationId,
        'message': 'Application not found.',
      });
    }

    final wasReloaded = await instance.runner.reload();

    if (wasReloaded) {
      return DaemonResponse.success(id: request.id, result: {
        'applicationId': applicationId,
      });
    }
    return DaemonResponse.error(id: request.id, error: {
      'applicationId': applicationId,
    });
  }

  Future<DaemonResponse> stop(DaemonRequest request) async {
    // todo: handle malformed params
    final applicationId = request.params['applicationId'] as String;
    final instance = _instances[applicationId];
    if (instance == null) {
      return DaemonResponse.error(id: request.id, error: {
        'applicationId': applicationId,
        'message': 'Application not found',
      });
    }

    instance.runner.terminate();
    _instances.remove(applicationId);

    return DaemonResponse.success(id: request.id, result: {
      'applicationId': applicationId,
    });
  }
}

class ApplicationInstance {
  ApplicationInstance(this.runner, this.id);

  final DevServerRunner runner;
  final String id;
}
