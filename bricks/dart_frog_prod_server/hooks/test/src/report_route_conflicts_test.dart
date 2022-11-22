import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason/mason.dart' hide createBundle;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../src/report_route_conflicts.dart';

class _MockHookContext extends Mock implements HookContext {}

class _MockLogger extends Mock implements Logger {}

class _MockRouteConfiguration extends Mock implements RouteConfiguration {}

void main() {
  group('reportRouteConflicts', () {
    late HookContext context;
    late Logger logger;
    late RouteConfiguration configuration;

    setUp(() {
      context = _MockHookContext();
      logger = _MockLogger();
      configuration = _MockRouteConfiguration();

      when(() => context.logger).thenReturn(logger);
    });

    test('reports nothing when there are no endpoints', () {
      final exitCalls = <int>[];
      when(() => configuration.endpoints).thenReturn({});
      reportRouteConflicts(context, configuration, exitCalls.add);
      verifyNever(() => logger.err(any()));
      expect(exitCalls, isEmpty);
    });

    test('reports nothing when there are endpoints and no conflicts', () {
      final exitCalls = <int>[];
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
      reportRouteConflicts(context, configuration, exitCalls.add);
      verifyNever(() => logger.err(any()));
      expect(exitCalls, isEmpty);
    });

    test(
        'reports single conflict '
        'when there is one endpoint with conflicts', () {
      final exitCalls = <int>[];
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
      reportRouteConflicts(context, configuration, exitCalls.add);
      verify(
        () => logger.err(
          '''Route conflict detected. ${lightCyan.wrap('routes/hello.dart')} and ${lightCyan.wrap('routes/hello/index.dart')} both resolve to ${lightCyan.wrap('/hello')}.''',
        ),
      );
      expect(exitCalls, equals([1]));
    });

    test(
        'reports multiple conflicts '
        'when there are multiple endpoint with conflicts', () {
      final exitCalls = <int>[];
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
      reportRouteConflicts(context, configuration, exitCalls.add);
      verify(
        () => logger.err(
          '''Route conflict detected. ${lightCyan.wrap('routes/hello.dart')} and ${lightCyan.wrap('routes/hello/index.dart')} both resolve to ${lightCyan.wrap('/hello')}.''',
        ),
      );
      verify(
        () => logger.err(
          '''Route conflict detected. ${lightCyan.wrap('routes/echo.dart')} and ${lightCyan.wrap('routes/echo/index.dart')} both resolve to ${lightCyan.wrap('/echo')}.''',
        ),
      );
      expect(exitCalls, equals([1]));
    });
  });
}
