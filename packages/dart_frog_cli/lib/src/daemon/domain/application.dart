import 'package:dart_frog_cli/src/daemon/dev_server_runner.dart';
import 'package:mason/mason.dart';

import '../protocol.dart';
import 'domain.dart';

class ApplicationDomain extends Domain {
  ApplicationDomain(super.daemon) {
    addHandler('run', run);
  }

  @override
  String get name => 'application';

  Map<String, ApplicationInstance> instances = {};

  void run(DaemonRequest request) async {
    final port = request.params['port'] as String?;
    final dartVmServicePort = request.params['dartVmServicePort'] as String?;

    final applicationId = getId();

    final instance =  instances[applicationId] = ApplicationInstance(
      DevServerRunner(
        port: port,
        dartVmServicePort: dartVmServicePort,
        logger: daemon.logger,
      ),
      request.id,
    );

    final exitCode = await instance.runner.run();

    if(exitCode == ExitCode.success) {
      daemon.conenction.send(
        DaemonResponse.success(
            id: request.id,
            result: {
              'exitCode': exitCode.code,
              'applicationId': applicationId,
            }
        ),
      );
    } else {
      daemon.conenction.send(
        DaemonResponse.error(
            id: request.id,
            error: {
              'exitCode': exitCode.code,
              'applicationId': applicationId,
            }
        ),
      );
    }


  }
}

class ApplicationInstance {
  ApplicationInstance(this.runner, this.id);

  final DevServerRunner runner;
  final String id;
}
