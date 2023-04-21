import 'package:dart_frog_gen/dart_frog_gen.dart';

import 'package:mocktail/mocktail.dart';
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
          ),
        ],
        '/hello': const [
          RouteFile(
            name: 'hello',
            path: 'hello.dart',
            route: '/hello',
            params: [],
          )
        ]
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
          ),
        ],
        '/hello': const [
          RouteFile(
            name: 'hello',
            path: 'hello.dart',
            route: '/hello',
            params: [],
          ),
          RouteFile(
            name: 'hello_index',
            path: 'hello/index.dart',
            route: '/',
            params: [],
          )
        ]
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
          ),
        ],
        '/hello': const [
          RouteFile(
            name: 'hello',
            path: 'hello.dart',
            route: '/hello',
            params: [],
          ),
          RouteFile(
            name: 'hello_index',
            path: 'hello/index.dart',
            route: '/',
            params: [],
          )
        ],
        '/echo': const [
          RouteFile(
            name: 'echo',
            path: 'echo.dart',
            route: '/echo',
            params: [],
          ),
          RouteFile(
            name: 'echo_index',
            path: 'echo/index.dart',
            route: '/',
            params: [],
          )
        ]
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
      expect(conflicts, ['/hello', '/echo']);
    });
  });
}
