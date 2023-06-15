import 'dart:async';

import 'package:dart_frog_cli/src/daemon/domain/domain.dart';

import '../logger.dart';
import '../project_analyzer.dart';
import '../protocol.dart';

class RouteConfigDomain extends Domain {
  RouteConfigDomain(super.daemon) {
    addHandler('analyzeStart', analyzeStart);
    addHandler('analyzeStop', analyzeStop);
  }

  @override
  String get name => 'projectAnalyzer';

  Map<String, ProjectAnalyzerInstance> _instances = {};

  Future<DaemonResponse> analyzeStart(DaemonRequest request) async {
    final analyzeId = getId();

    final workingDirectory = request.params['workingDirectory'] as String;
    final analyzerId = getId();
    final instance = _instances[analyzerId] = ProjectAnalyzerInstance(
      RouteConfigMonitor(
        workingDirectory: workingDirectory,
        logger: DaemonLogger(this, {
          'analyzerId': analyzerId,
          'workingDirectory': workingDirectory,
        }),
        onRouteConfigurationChanged: (routeConfiguration) {
          daemon.send(
            DaemonEvent(
              domain: name,
              event: 'routeConfigurationChanged',
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

    Timer.run(instance.analyzer.regenerateRouteConfig);

    return DaemonResponse.success(id: request.id, result: {
      'analyzerId': analyzerId,
    });
  }

  Future<DaemonResponse> analyzeStop(DaemonRequest request) async {
    // todo: handle malformed params
    final analyzerId = request.params['analyzerId'] as String;
    final instance = _instances[analyzerId];
    if (instance == null) {
      return DaemonResponse.error(id: request.id, error: {
        'analyzerId': analyzerId,
        'message': 'Analyzer not found',
      });
    }
    instance.analyzer.terminate();
    _instances.remove(analyzerId);

    return DaemonResponse.success(id: request.id, result: {
      'analyzerId': analyzerId,
    });
  }
}

class ProjectAnalyzerInstance {
  ProjectAnalyzerInstance(this.analyzer, this.id);

  final RouteConfigMonitor analyzer;
  final String id;
}
