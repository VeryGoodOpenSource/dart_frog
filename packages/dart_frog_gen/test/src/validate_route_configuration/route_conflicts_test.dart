import 'package:dart_frog_gen/route_configuration.dart';

import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

class _MockRouteConfiguration extends Mock implements RouteConfiguration {}

void main() {
  group('reportRouteConflicts', () {
    late RouteConfiguration configuration;

    late bool violationStartCalled;
    late bool violationEndCalled;
    late List<String> conflicts;

    setUp(() {
      configuration = _MockRouteConfiguration();

      violationStartCalled = false;
      violationEndCalled = false;
      conflicts = [];
    });

    test('reports nothing when there are no endpoints', () {
      when(() => configuration.endpoints).thenReturn({});

      reportRouteConflicts(
        configuration,
        onViolationStart: () {
          violationStartCalled = true;
        },
        onRouteConflict: (_, __, conflictingEndpoint) {
          conflicts.add(conflictingEndpoint);
        },
        onViolationEnd: () {
          violationEndCalled = true;
        },
      );

      expect(violationStartCalled, isFalse);
      expect(violationEndCalled, isFalse);
      expect(conflicts, isEmpty);
    });

    test('reports nothing when there are endpoints and no conflicts', () {
      when(() => configuration.endpoints).thenReturn({
        '/': const [
          RouteFile(
            name: 'index',
            path: 'index.dart',
            route: '/',
            params: [],
            wildcard: false,
          ),
        ],
        '/hello': const [
          RouteFile(
            name: 'hello',
            path: 'hello.dart',
            route: '/hello',
            params: [],
            wildcard: false,
          ),
        ],
      });

      reportRouteConflicts(
        configuration,
        onViolationStart: () {
          violationStartCalled = true;
        },
        onRouteConflict: (_, __, conflictingEndpoint) {
          conflicts.add(conflictingEndpoint);
        },
        onViolationEnd: () {
          violationEndCalled = true;
        },
      );

      expect(violationStartCalled, isFalse);
      expect(violationEndCalled, isFalse);
      expect(conflicts, isEmpty);
    });

    test('reports single conflict when there is one endpoint with conflicts',
        () {
      when(() => configuration.endpoints).thenReturn({
        '/': const [
          RouteFile(
            name: 'index',
            path: 'index.dart',
            route: '/',
            params: [],
            wildcard: false,
          ),
        ],
        '/hello': const [
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
      });

      reportRouteConflicts(
        configuration,
        onViolationStart: () {
          violationStartCalled = true;
        },
        onRouteConflict: (_, __, conflictingEndpoint) {
          conflicts.add(conflictingEndpoint);
        },
        onViolationEnd: () {
          violationEndCalled = true;
        },
      );

      expect(violationStartCalled, isTrue);
      expect(violationEndCalled, isTrue);
      expect(conflicts, ['/hello']);
    });

    test(
        'reports multiple conflicts '
        'when there are multiple endpoint with conflicts', () {
      when(() => configuration.endpoints).thenReturn({
        '/': const [
          RouteFile(
            name: 'index',
            path: 'index.dart',
            route: '/',
            params: [],
            wildcard: false,
          ),
        ],
        '/hello': const [
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
        '/echo': const [
          RouteFile(
            name: 'echo',
            path: 'echo.dart',
            route: '/echo',
            params: [],
            wildcard: false,
          ),
          RouteFile(
            name: 'echo_index',
            path: 'echo/index.dart',
            route: '/',
            params: [],
            wildcard: false,
          ),
        ],
      });

      reportRouteConflicts(
        configuration,
        onViolationStart: () {
          violationStartCalled = true;
        },
        onRouteConflict: (_, __, conflictingEndpoint) {
          conflicts.add(conflictingEndpoint);
        },
        onViolationEnd: () {
          violationEndCalled = true;
        },
      );

      expect(violationStartCalled, isTrue);
      expect(violationEndCalled, isTrue);
      expect(conflicts, ['/hello', '/echo']);
    });

    test(
      'reports error when dynamic directories conflict with non dynamic files',
      () {
        when(() => configuration.endpoints).thenReturn({
          '/cars/<id>': const [
            RouteFile(
              name: r'cars_$id_index',
              path: '../routes/cars/[id]/index.dart',
              route: '/',
              params: [],
              wildcard: false,
            ),
          ],
          '/cars/mine': const [
            RouteFile(
              name: 'cars_mine',
              path: '../routes/cars/mine.dart',
              route: '/mine',
              params: [],
              wildcard: false,
            ),
          ],
        });

        reportRouteConflicts(
          configuration,
          onViolationStart: () {
            violationStartCalled = true;
          },
          onRouteConflict: (
            originalFilePath,
            conflictingFilePath,
            conflictingEndpoint,
          ) {
            conflicts.add('$originalFilePath and '
                '$conflictingFilePath -> '
                '$conflictingEndpoint');
          },
          onViolationEnd: () {
            violationEndCalled = true;
          },
        );

        expect(violationStartCalled, isTrue);
        expect(violationEndCalled, isTrue);
        expect(
          conflicts,
          equals(
            [
              '${path.normalize('/cars/<id>')} and ${path.normalize('//cars/mine')} -> /cars/<id>',
            ],
          ),
        );
      },
    );

    test(
      'reports error when dynamic directories conflict with non dynamic files, '
      'with multiple folders',
      () {
        when(() => configuration.endpoints).thenReturn({
          '/turtles/random': const [
            RouteFile(
              name: 'turtles_random',
              path: '../routes/turtles/random.dart',
              route: '/',
              params: [],
              wildcard: false,
            ),
          ],
          '/turtles/<id>': const [
            RouteFile(
              name: r'turtles_$id_index',
              path: '../routes/turtles/[id]/index.dart',
              route: '/turtles/<id>',
              params: [],
              wildcard: false,
            ),
          ],
          '/turtles/<id>/bla': const [
            RouteFile(
              name: r'turtles_$id_bla',
              path: '../routes/turtles/[id]/bla.dart',
              route: '/turtles/<id>/bla.dart',
              params: [],
              wildcard: false,
            ),
          ],
          '/turtles/<id>/<name>': const [
            RouteFile(
              name: r'turtles_$id_$name_index',
              path: '../routes/turtles/[id]/[name]/index.dart',
              route: '/turtles/<id>/<name>/index.dart',
              params: [],
              wildcard: false,
            ),
          ],
          '/turtles/<id>/<name>/ble.dart': const [
            RouteFile(
              name: r'turtles_$id_$name_ble.dart',
              path: '../routes/turtles/[id]/[name]/ble.dart',
              route: '/turtles/<id>/<name>/ble.dart',
              params: [],
              wildcard: false,
            ),
          ],
        });

        reportRouteConflicts(
          configuration,
          onViolationStart: () {
            violationStartCalled = true;
          },
          onRouteConflict: (
            originalFilePath,
            conflictingFilePath,
            conflictingEndpoint,
          ) {
            conflicts.add(
              '$originalFilePath and '
              '$conflictingFilePath -> '
              '$conflictingEndpoint',
            );
          },
          onViolationEnd: () {
            violationEndCalled = true;
          },
        );

        expect(violationStartCalled, isTrue);
        expect(violationEndCalled, isTrue);
        expect(
          conflicts,
          [
            '${path.normalize('/turtles/<id>')} and ${path.normalize('/turtles/random')} -> /turtles/<id>',
            '${path.normalize('/turtles/<id>/<name>')} and ${path.normalize('/turtles/<id>/bla')} -> /turtles/<id>/<name>',
          ],
        );
      },
    );
  });
}
