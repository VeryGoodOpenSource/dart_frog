import 'dart:async';

import 'package:dart_frog_cli/src/daemon/daemon.dart';

class RouteConfigDomain extends Domain {
  RouteConfigDomain(super.daemon) {
    addHandler('monitorStart', monitorStart);
    addHandler('monitorStop', monitorStop);
  }

  @override
  String get name => 'routeConfig';

  final _instances = <String, RouteConfigMonitorInstance>{};

  Future<DaemonResponse> monitorStart(DaemonRequest request) async {
    final analyzeId = getId();

    final workingDirectory = request.params['workingDirectory'] as String;
    final monitorId = getId();
    final instance = _instances[monitorId] = RouteConfigMonitorInstance(
      RouteConfigMonitor(
        workingDirectory: workingDirectory,
        logger: DaemonLogger(this, {
          'monitorId': monitorId,
          'workingDirectory': workingDirectory,
        }),
        onRouteConfigurationChanged: (routeConfiguration) {
          daemon.send(
            DaemonEvent(
              domain: name,
              event: 'routeConfigurationChanged',
              params: {
                'monitorId': monitorId,
                'routeConfiguration': routeConfiguration.toJson(),
              },
            ),
          );
        },
      ),
      analyzeId,
    );
    await instance.monitor.start();

    Timer.run(instance.monitor.regenerateRouteConfig);

    return DaemonResponse.success(
      id: request.id,
      result: {
        'monitorId': monitorId,
      },
    );
  }

  Future<DaemonResponse> monitorStop(DaemonRequest request) async {
    // todo: handle malformed params
    final monitorId = request.params['monitorId'] as String;
    final instance = _instances[monitorId];
    if (instance == null) {
      return DaemonResponse.error(
        id: request.id,
        error: {
          'monitorId': monitorId,
          'message': 'Analyzer not found',
        },
      );
    }
    instance.monitor.terminate();
    _instances.remove(monitorId);

    return DaemonResponse.success(
      id: request.id,
      result: {
        'monitorId': monitorId,
      },
    );
  }
}

class RouteConfigMonitorInstance {
  RouteConfigMonitorInstance(this.monitor, this.id);

  final RouteConfigMonitor monitor;
  final String id;
}
