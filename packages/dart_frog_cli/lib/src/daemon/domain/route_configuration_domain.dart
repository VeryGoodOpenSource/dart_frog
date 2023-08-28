import 'dart:async';
import 'dart:io' as io;

import 'package:dart_frog_cli/src/daemon/daemon.dart';
import 'package:dart_frog_cli/src/route_configuration_watcher/route_configuration_watcher.dart';
import 'package:meta/meta.dart';

/// {@template route_config_domain}
/// A [DomainBase] which includes operations for starting and stopping
/// [RouteConfigurationWatcher]s.
/// {@endtemplate}
class RouteConfigurationDomain extends DomainBase {
  /// {@macro route_config_domain}
  RouteConfigurationDomain(
    super.daemon, {
    @visibleForTesting super.getId,
    @visibleForTesting
    RouteConfigurationWatcherBuilder? routeConfigurationWatcherBuilder,
  }) : _routeConfigWatcherBuilder =
            routeConfigurationWatcherBuilder ?? RouteConfigurationWatcher.new {
    addHandler('watcherStart', _watcherStart);
    addHandler(
      'watcherGenerateRouteConfiguration',
      _watcherGenerateRouteConfiguration,
    );
    addHandler('watcherStop', _watcherStop);
  }

  @override
  String get domainName => 'route_config';

  final _routeConfigurationWatchers = <String, RouteConfigurationWatcher>{};

  final RouteConfigurationWatcherBuilder _routeConfigWatcherBuilder;

  Future<DaemonResponse> _watcherStart(DaemonRequest request) async {
    final workingDirectory = request.params?['workingDirectory'];
    if (workingDirectory is! String) {
      throw const DartFrogDaemonMalformedMessageException(
        'invalid workingDirectory',
      );
    }

    final watcherId = getId();

    final logger = DaemonLogger(
      domain: domainName,
      params: {
        'watcherId': watcherId,
        'requestId': request.id,
        'workingDirectory': workingDirectory,
      },
      sendEvent: daemon.sendEvent,
      idGenerator: getId,
    );

    final routeConfigWatcher = _routeConfigWatcherBuilder(
      logger: logger,
      workingDirectory: io.Directory(workingDirectory),
      onRouteConfigurationChanged: (routeConfiguration) {
        daemon.sendEvent(
          DaemonEvent(
            domain: domainName,
            event: 'routeConfigurationChanged',
            params: {
              'watcherId': watcherId,
              'requestId': request.id,
              'routeConfiguration': routeConfiguration.toJson(),
            },
          ),
        );
      },
    );

    await routeConfigWatcher.start();

    // Queue up a regeneration of the route config so that it happens after the
    // daemon has responded to the client.
    Timer.run(routeConfigWatcher.forceRouteConfigurationRegeneration);

    return DaemonResponse.success(
      id: request.id,
      result: {
        'watcherId': watcherId,
      },
    );
  }

  Future<DaemonResponse> _watcherGenerateRouteConfiguration(
    DaemonRequest request,
  ) async {
    final watcherId = request.params?['watcherId'];
    if (watcherId is! String) {
      throw const DartFrogDaemonMalformedMessageException(
        'invalid watcherId',
      );
    }

    final watcher = _routeConfigurationWatchers[watcherId];
    if (watcher == null) {
      return DaemonResponse.error(
        id: request.id,
        error: {
          'watcherId': watcherId,
          'message': 'Watcher not found',
        },
      );
    }

    final routeConfiguration = watcher.forceRouteConfigurationRegeneration();

    if (routeConfiguration == null) {
      return DaemonResponse.error(
        id: request.id,
        error: {
          'watcherId': watcherId,
          'message': 'Could not regenerate route configuration',
        },
      );
    }

    return DaemonResponse.success(
      id: request.id,
      result: {
        'watcherId': watcherId,
        'routeConfiguration': routeConfiguration.toJson(),
      },
    );
  }

  Future<DaemonResponse> _watcherStop(DaemonRequest request) async {
    final watcherId = request.params?['watcherId'];
    if (watcherId is! String) {
      throw const DartFrogDaemonMalformedMessageException(
        'invalid watcherId',
      );
    }

    final watcher = _routeConfigurationWatchers[watcherId];
    if (watcher == null) {
      return DaemonResponse.error(
        id: request.id,
        error: {
          'watcherId': watcherId,
          'message': 'Watcher not found',
        },
      );
    }

    await watcher.stop();

    return DaemonResponse.success(
      id: request.id,
      result: {
        'watcherId': watcherId,
      },
    );
  }

  @override
  Future<void> dispose() async {
    for (final watcher in _routeConfigurationWatchers.values) {
      await watcher.stop();
    }
    _routeConfigurationWatchers.clear();
  }
}
