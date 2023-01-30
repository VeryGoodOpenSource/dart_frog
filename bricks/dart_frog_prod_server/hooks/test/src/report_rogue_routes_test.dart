import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../src/report_rogue_routes.dart';

class _MockHookContext extends Mock implements HookContext {}

class _MockLogger extends Mock implements Logger {}

class _MockRouteConfiguration extends Mock implements RouteConfiguration {}

void main() {
  group('reportRogueRoutes', () {
    late HookContext context;
    late Logger logger;
    late RouteConfiguration configuration;

    setUp(() {
      context = _MockHookContext();
      logger = _MockLogger();
      configuration = _MockRouteConfiguration();

      when(() => context.logger).thenReturn(logger);
    });

    test('reports nothing when there are no rogue routes', () {
      final exitCalls = <int>[];
      when(() => configuration.rogueRoutes).thenReturn([]);
      reportRogueRoutes(context, configuration, exitCalls.add);
      verifyNever(() => logger.err(any()));
      expect(exitCalls, isEmpty);
    });

    test('reports single rogue route', () {
      final exitCalls = <int>[];
      when(() => configuration.rogueRoutes).thenReturn(
        const [
          RouteFile(
            name: 'hello',
            path: 'hello.dart',
            route: '/hello',
            params: [],
          ),
        ],
      );
      reportRogueRoutes(context, configuration, exitCalls.add);
      verify(
        () => logger.err(
          '''Rogue route detected.${defaultForeground.wrap(' ')}Rename ${lightCyan.wrap('routes/hello.dart')} to ${lightCyan.wrap('routes/hello/index.dart')}.''',
        ),
      );
      expect(exitCalls, equals([1]));
    });

    test('reports multiple rogue routes', () {
      final exitCalls = <int>[];
      when(() => configuration.rogueRoutes).thenReturn(
        const [
          RouteFile(
            name: 'hello',
            path: 'hello.dart',
            route: '/hello',
            params: [],
          ),
          RouteFile(
            name: 'hi',
            path: 'hi.dart',
            route: '/hi',
            params: [],
          ),
        ],
      );
      reportRogueRoutes(context, configuration, exitCalls.add);
      verify(
        () => logger.err(
          '''Rogue route detected.${defaultForeground.wrap(' ')}Rename ${lightCyan.wrap('routes/hello.dart')} to ${lightCyan.wrap('routes/hello/index.dart')}.''',
        ),
      );
      verify(
        () => logger.err(
          '''Rogue route detected.${defaultForeground.wrap(' ')}Rename ${lightCyan.wrap('routes/hi.dart')} to ${lightCyan.wrap('routes/hi/index.dart')}.''',
        ),
      );
      expect(exitCalls, equals([1]));
    });
  });
}
