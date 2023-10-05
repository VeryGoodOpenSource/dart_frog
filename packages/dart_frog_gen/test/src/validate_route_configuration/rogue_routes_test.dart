import 'package:dart_frog_gen/route_configuration.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

class _MockRouteConfiguration extends Mock implements RouteConfiguration {}

void main() {
  group('reportRogueRoutes', () {
    late RouteConfiguration configuration;

    late bool violationStartCalled;
    late bool violationEndCalled;
    late List<String> rogueRoutes;

    setUp(() {
      configuration = _MockRouteConfiguration();

      violationStartCalled = false;
      violationEndCalled = false;
      rogueRoutes = [];
    });

    test('reports nothing when there are no rogue routes', () {
      when(() => configuration.rogueRoutes).thenReturn([]);

      reportRogueRoutes(
        configuration,
        onViolationStart: () {
          violationStartCalled = true;
        },
        onRogueRoute: (filePath, idealPath) {
          rogueRoutes.add(filePath);
        },
        onViolationEnd: () {
          violationEndCalled = true;
        },
      );

      expect(violationStartCalled, isFalse);
      expect(violationEndCalled, isFalse);
      expect(rogueRoutes, isEmpty);
    });

    test('reports single rogue route', () {
      when(() => configuration.rogueRoutes).thenReturn(
        const [
          RouteFile(
            name: 'hello',
            path: 'hello.dart',
            route: '/hello',
            params: [],
            wildcard: false,
          ),
        ],
      );

      reportRogueRoutes(
        configuration,
        onViolationStart: () {
          violationStartCalled = true;
        },
        onRogueRoute: (filePath, idealPath) {
          rogueRoutes.add(filePath);
        },
        onViolationEnd: () {
          violationEndCalled = true;
        },
      );

      expect(violationStartCalled, isTrue);
      expect(violationEndCalled, isTrue);
      expect(rogueRoutes, [p.join('routes', 'hello.dart')]);
    });

    test('reports multiple rogue routes', () {
      when(() => configuration.rogueRoutes).thenReturn(
        const [
          RouteFile(
            name: 'hello',
            path: 'hello.dart',
            route: '/hello',
            params: [],
            wildcard: false,
          ),
          RouteFile(
            name: 'hi',
            path: 'hi.dart',
            route: '/hi',
            params: [],
            wildcard: false,
          ),
        ],
      );

      reportRogueRoutes(
        configuration,
        onViolationStart: () {
          violationStartCalled = true;
        },
        onRogueRoute: (filePath, idealPath) {
          rogueRoutes.add(filePath);
        },
        onViolationEnd: () {
          violationEndCalled = true;
        },
      );

      expect(violationStartCalled, isTrue);
      expect(violationEndCalled, isTrue);
      expect(rogueRoutes, [
        p.join('routes', 'hello.dart'),
        p.join('routes', 'hi.dart'),
      ]);
    });
  });
}
