import 'dart:async';
import 'dart:io';

import 'package:dart_frog_cli/src/daemon/daemon.dart';
import 'package:dart_frog_cli/src/route_configuration_watcher/route_configuration_watcher.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockDaemonServer extends Mock implements DaemonServer {}

class _MockRouteConfigurationWatcher extends Mock
    implements RouteConfigurationWatcher {}

class _FakeDaemonEvent extends Fake implements DaemonEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeDaemonEvent());
  });

  group('$RouteConfigurationDomain', () {
    late DaemonServer daemonServer;
    late Completer<ExitCode> completer;
    late RouteConfigurationWatcher watcher;

    late RouteConfigurationDomain domain;

    setUp(() {
      daemonServer = _MockDaemonServer();
      watcher = _MockRouteConfigurationWatcher();
      completer = Completer();

      domain = RouteConfigurationDomain(
        daemonServer,
        getId: () => 'id',
        routeConfigurationWatcherBuilder: ({
          required Logger logger,
          required Directory workingDirectory,
          required RouteConfigurationChanged onRouteConfigurationChanged,
        }) {
          return watcher;
        },
      );

      when(() => watcher.start()).thenAnswer((_) async {});
      when(() => watcher.exitCode).thenAnswer((_) async => completer.future);
    });

    test('can be instantiated', () {
      expect(RouteConfigurationDomain(daemonServer), isNotNull);
    });

    group('watcherStart', () {
      test('starts a route config watcher', () async {
        late Logger passedLogger;
        late Directory passedWorkingDirectory;
        domain = RouteConfigurationDomain(
          daemonServer,
          getId: () => 'id',
          routeConfigurationWatcherBuilder: ({
            required Logger logger,
            required Directory workingDirectory,
            required RouteConfigurationChanged onRouteConfigurationChanged,
          }) {
            passedLogger = logger;
            passedWorkingDirectory = workingDirectory;
            return watcher;
          },
        );

        const request = DaemonRequest(
          id: '12',
          domain: 'route_config',
          method: 'watcherStart',
          params: {
            'workingDirectory': '/',
          },
        );

        expect(
          await domain.handleRequest(request),
          equals(
            const DaemonResponse.success(id: '12', result: {'watcherId': 'id'}),
          ),
        );

        expect(passedLogger, isA<DaemonLogger>());
        expect(passedWorkingDirectory.path, equals('/'));

        verify(() => watcher.start()).called(1);
      });
    });

    group('watcherStop', () {});

    group('watcherGenerateRouteConfiguration', () {});

    group('dispose', () {});
  });
}
