import 'dart:async';
import 'dart:io';

import 'package:dart_frog_cli/src/daemon/daemon.dart';
import 'package:dart_frog_cli/src/route_configuration_watcher/route_configuration_watcher.dart';
import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockDaemonServer extends Mock implements DaemonServer {}

class _MockRouteConfigurationWatcher extends Mock
    implements RouteConfigurationWatcher {}

class _FakeDaemonEvent extends Fake implements DaemonEvent {}

const _configuration = RouteConfiguration(
  middleware: [],
  directories: [],
  routes: [],
  rogueRoutes: [],
  endpoints: {
    '/': [
      RouteFile(
        name: 'index',
        path: 'index.dart',
        route: '/',
        params: [],
        wildcard: false,
      ),
    ],
    '/hello': [
      RouteFile(
        name: 'hello',
        path: 'hello.dart',
        route: '/hello',
        params: [],
        wildcard: false,
      ),
      RouteFile(
        name: 'hello_index',
        path: 'hello/index.dart',
        route: '/',
        params: [],
        wildcard: false,
      ),
    ],
  },
);

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

        expect(
          await domain.handleRequest(
            const DaemonRequest(
              id: '12',
              domain: 'route_config',
              method: 'watcherStart',
              params: {'workingDirectory': '/'},
            ),
          ),
          equals(
            const DaemonResponse.success(id: '12', result: {'watcherId': 'id'}),
          ),
        );

        expect(passedLogger, isA<DaemonLogger>());
        expect(passedWorkingDirectory.path, equals('/'));

        verify(() => watcher.start()).called(1);
      });

      group('malformed messages', () {
        test('workingDirectory', () async {
          expect(
            await domain.handleRequest(
              const DaemonRequest(
                id: '12',
                domain: 'route_config',
                method: 'watcherStart',
                params: {'workingDirectory': 123},
              ),
            ),
            equals(
              const DaemonResponse.error(
                id: '12',
                error: {
                  'message': 'Malformed message, invalid workingDirectory',
                },
              ),
            ),
          );
        });
      });

      test('on dev server throw', () async {
        when(() => watcher.start()).thenThrow('error');

        expect(
          await domain.handleRequest(
            const DaemonRequest(
              id: '12',
              domain: 'route_config',
              method: 'watcherStart',
              params: {'workingDirectory': '/'},
            ),
          ),
          equals(
            const DaemonResponse.error(
              id: '12',
              error: {'watcherId': 'id', 'message': 'error'},
            ),
          ),
        );
      });
    });

    group('watcherStop', () {
      setUp(() async {
        when(() => watcher.stop()).thenAnswer((_) async {});

        await domain.handleRequest(
          const DaemonRequest(
            id: '12',
            domain: 'route_config',
            method: 'watcherStart',
            params: {'workingDirectory': '/'},
          ),
        );
      });

      test('should stop', () async {
        completer.complete(ExitCode.success);
        expect(
          await domain.handleRequest(
            const DaemonRequest(
              id: '12',
              domain: 'route_config',
              method: 'watcherStop',
              params: {
                'watcherId': 'id',
              },
            ),
          ),
          equals(
            const DaemonResponse.success(
              id: '12',
              result: {
                'watcherId': 'id',
                'exitCode': 0,
              },
            ),
          ),
        );

        verify(() => watcher.stop()).called(1);
      });

      group('malformed messages', () {
        test('watcherId', () async {
          expect(
            await domain.handleRequest(
              const DaemonRequest(
                id: '12',
                domain: 'route_config',
                method: 'watcherStop',
                params: {
                  'watcherId': 123,
                },
              ),
            ),
            equals(
              const DaemonResponse.error(
                id: '12',
                error: {
                  'message': 'Malformed message, invalid watcherId',
                },
              ),
            ),
          );
        });

        test('watcher not found', () async {
          expect(
            await domain.handleRequest(
              const DaemonRequest(
                id: '12',
                domain: 'dev_server',
                method: 'watcherStop',
                params: {'watcherId': 'different-id'},
              ),
            ),
            equals(
              const DaemonResponse.error(
                id: '12',
                error: {
                  'watcherId': 'different-id',
                  'message': 'Watcher not found',
                },
              ),
            ),
          );
        });
      });

      test('on dev server throw', () async {
        when(() => watcher.stop()).thenThrow('error');

        expect(
          await domain.handleRequest(
            const DaemonRequest(
              id: '12',
              domain: 'route_config',
              method: 'watcherStop',
              params: {
                'watcherId': 'id',
              },
            ),
          ),
          equals(
            const DaemonResponse.error(
              id: '12',
              error: {'watcherId': 'id', 'message': 'error'},
            ),
          ),
        );
      });
    });

    group('watcherGenerateRouteConfiguration', () {
      setUp(() async {
        when(() => watcher.forceRouteConfigurationRegeneration())
            .thenReturn(_configuration);

        await domain.handleRequest(
          const DaemonRequest(
            id: '12',
            domain: 'route_config',
            method: 'watcherStart',
            params: {'workingDirectory': '/'},
          ),
        );
      });

      test('should regenerate route config', () async {
        completer.complete(ExitCode.success);
        expect(
          await domain.handleRequest(
            const DaemonRequest(
              id: '12',
              domain: 'route_config',
              method: 'watcherGenerateRouteConfiguration',
              params: {
                'watcherId': 'id',
              },
            ),
          ),
          equals(
            DaemonResponse.success(
              id: '12',
              result: {
                'watcherId': 'id',
                'routeConfiguration': _configuration.toJson(),
              },
            ),
          ),
        );

        verify(() => watcher.forceRouteConfigurationRegeneration()).called(1);
      });

      group('malformed messages', () {
        test('watcherId', () async {
          expect(
            await domain.handleRequest(
              const DaemonRequest(
                id: '12',
                domain: 'route_config',
                method: 'watcherGenerateRouteConfiguration',
                params: {
                  'watcherId': 123,
                },
              ),
            ),
            equals(
              const DaemonResponse.error(
                id: '12',
                error: {
                  'message': 'Malformed message, invalid watcherId',
                },
              ),
            ),
          );
        });

        test('watcher not found', () async {
          expect(
            await domain.handleRequest(
              const DaemonRequest(
                id: '12',
                domain: 'dev_server',
                method: 'watcherGenerateRouteConfiguration',
                params: {'watcherId': 'different-id'},
              ),
            ),
            equals(
              const DaemonResponse.error(
                id: '12',
                error: {
                  'watcherId': 'different-id',
                  'message': 'Watcher not found',
                },
              ),
            ),
          );
        });
      });

      test('when cannot generate route config', () async {
        when(() => watcher.forceRouteConfigurationRegeneration())
            .thenReturn(null);

        expect(
          await domain.handleRequest(
            const DaemonRequest(
              id: '12',
              domain: 'route_config',
              method: 'watcherGenerateRouteConfiguration',
              params: {
                'watcherId': 'id',
              },
            ),
          ),
          equals(
            const DaemonResponse.error(
              id: '12',
              error: {
                'watcherId': 'id',
                'message': 'Could not regenerate route configuration',
              },
            ),
          ),
        );

        verify(() => watcher.forceRouteConfigurationRegeneration()).called(1);
      });
    });

    group('dispose', () {});
  });
}
