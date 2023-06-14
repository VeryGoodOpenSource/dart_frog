import 'package:dart_frog_cli/src/daemon/domain/domain.dart';

import '../logger.dart';
import '../project_analyzer.dart';
import '../protocol.dart';

// todo: didnt have a better name for this
class ProjectAnalyzerDomain extends Domain {
  ProjectAnalyzerDomain(super.daemon) {
    addHandler('analyze', analyze);
    addHandler('analyzeStop', analyzeStop);
  }

  @override
  String get name => 'projectAnalyzer';

  Map<String, ProjectAnalyzerInstance> instances = {};

  void analyze(DaemonRequest request) async {
    final analyzeId = getId();

    final workingDirectory = request.params['workingDirectory'] as String;
    final analyzerId = getId();
    final instance = instances[analyzerId] = ProjectAnalyzerInstance(
      ProjectAnalyzer(
        workingDirectory: workingDirectory,
        logger: DaemonLogger(this, {
          'analyzerId': analyzerId,
          'workingDirectory': workingDirectory,
        }),
        onRouteConfigurationChanged: (routeConfiguration) {
          daemon.conenction.send(
            DaemonEvent(
              domain: name,
              event: 'routeConfigurationChangeChanged',
              params: {
                'analyzerId': analyzerId,
                'routeConfiguration': routeConfiguration.toJson(),
              },
            ),
          );
        },
      ),
      analyzeId,
    );
    await instance.analyzer.start();
    instance.analyzer.regenerateRouteConfig();
    daemon.conenction.send(
      DaemonResponse.success(id: request.id, result: {
        'analyzerId': analyzerId,
      }),
    );
  }

  void analyzeStop(DaemonRequest request) async {
    final analyzerId = request.params['analyzerId'] as String;
    final instance = instances[analyzerId];
    if (instance != null) {
      instance.analyzer.terminate();
      instances.remove(analyzerId);

      return daemon.conenction.send(
        DaemonResponse.success(id: request.id, result: {
          'analyzerId': analyzerId,
        }),
      );
    }
    daemon.conenction.send(
      DaemonResponse.error(id: request.id, error: {
        'analyzerId': analyzerId,
        'message': 'Analyzer not found',
      }),
    );

  }
}

class ProjectAnalyzerInstance {
  ProjectAnalyzerInstance(this.analyzer, this.id);

  final ProjectAnalyzer analyzer;
  final String id;
}
