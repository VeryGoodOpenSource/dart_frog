import 'package:dart_frog_cli/src/daemon/dev_server_runner.dart';
import 'package:dart_frog_cli/src/daemon/domain/domain.dart';
import 'package:dart_frog_cli/src/daemon/logger.dart';
import 'package:dart_frog_cli/src/daemon/protocol.dart';
import 'package:mason/mason.dart';

class ApplicationDomain extends Domain {
  ApplicationDomain(super.daemon) {
    addHandler('run', run);
    addHandler('reload', reload);
  }

  @override
  String get name => 'application';

  Map<String, ApplicationInstance> instances = {};

  void run(DaemonRequest request) async {
    final port = request.params['port'] as String?;
    final dartVmServicePort = request.params['dartVmServicePort'] as String?;
    final workingDirectory = request.params['workingDirectory'] as String;

    final applicationId = getId();

    final Logger logger = DaemonLogger(this, {
      'applicationId': applicationId,
      'workingDirectory': workingDirectory,
    });

    final instance = instances[applicationId] = ApplicationInstance(
      DevServerRunner(
        port: port,
        dartVmServicePort: dartVmServicePort,
        logger: logger,
        workingDirectory: workingDirectory
      ),
      applicationId,
    );

    await instance.runner.run();

    instance.runner.exitCode.then((exitCode) {
      if (exitCode == ExitCode.success) {
        daemon.conenction.send(
          DaemonResponse.success(id: request.id, result: {
            'exitCode': exitCode.code,
            'applicationId': applicationId,
          }),
        );
      } else {
        daemon.conenction.send(
          DaemonResponse.error(id: request.id, error: {
            'exitCode': exitCode.code,
            'applicationId': applicationId,
          }),
        );
      }
    });
  }

  void reload(DaemonRequest request) async {
    // todo: handle malformed params
    final applicationId = request.params['applicationId'] as String;
    final instance = instances[applicationId];
    if (instance != null) {
      final wasReloaded = await instance.runner.reload();

      if (wasReloaded) {
        daemon.conenction.send(
          DaemonResponse.success(id: request.id, result: {
            'applicationId': applicationId,
          }),
        );
      } else {
        daemon.conenction.send(
          DaemonResponse.error(id: request.id, error: {
            'applicationId': applicationId,
          }),
        );
      }
    } else {
      daemon.conenction.send(
        DaemonResponse.error(id: request.id, error: {
          'applicationId': applicationId,
          'message': 'Application not found.',
        }),
      );
    }
  }
}

class ApplicationInstance {
  ApplicationInstance(this.runner, this.id);

  final DevServerRunner runner;
  final String id;
}
