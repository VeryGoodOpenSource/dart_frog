import 'dart:io';

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../pre_gen.dart';

class _MockHookContext extends Mock implements HookContext {}

class _FakeHookContext extends Fake implements HookContext {
  _FakeHookContext({Logger? logger}) : _logger = logger ?? _MockLogger();

  final Logger _logger;

  var _vars = <String, dynamic>{};

  @override
  Map<String, dynamic> get vars => _vars;

  @override
  set vars(Map<String, dynamic> value) => _vars = value;

  @override
  Logger get logger => _logger;
}

class _MockLogger extends Mock implements Logger {}

class _MockRouteConfiguration extends Mock implements RouteConfiguration {}

void main() {
  group('preGen', () {
    late HookContext context;
    late Logger logger;

    setUp(() {
      logger = _MockLogger();
      context = _FakeHookContext(logger: logger);
    });

    test('run completes', () {
      expect(
        ExitOverrides.runZoned(
          () => run(_FakeHookContext()),
          exit: (_) {},
        ),
        completes,
      );
    });

    test('exit(1) if buildRouteConfiguration throws', () async {
      final exitCalls = <int>[];
      final exception = Exception('oops');
      await preGen(
        context,
        buildConfiguration: (_) => throw exception,
        exit: exitCalls.add,
      );
      expect(exitCalls, equals([1]));
      verify(() => logger.err(exception.toString())).called(1);
    });

    test('retains custom port if specified', () async {
      const customPort = '8081';
      context.vars['port'] = customPort;
      const configuration = RouteConfiguration(
        middleware: [],
        directories: [],
        routes: [],
        rogueRoutes: [],
        endpoints: {},
      );
      final exitCalls = <int>[];
      await preGen(
        context,
        buildConfiguration: (_) => configuration,
        exit: exitCalls.add,
      );
      expect(exitCalls, isEmpty);
      verifyNever(() => logger.err(any()));
      expect(
        context.vars,
        equals({
          'port': customPort,
          'directories': <RouteDirectory>[],
          'routes': <RouteFile>[],
          'middleware': <MiddlewareFile>[],
          'globalMiddleware': false,
          'serveStaticFiles': false,
          'invokeCustomEntrypoint': false
        }),
      );
    });

    test('retains invokeCustomEntrypoint (true)', () async {
      const customPort = '8081';
      context.vars['port'] = customPort;
      const configuration = RouteConfiguration(
        middleware: [],
        directories: [],
        routes: [],
        rogueRoutes: [],
        endpoints: {},
        invokeCustomEntrypoint: true,
      );
      final exitCalls = <int>[];
      await preGen(
        context,
        buildConfiguration: (_) => configuration,
        exit: exitCalls.add,
      );
      expect(exitCalls, isEmpty);
      verifyNever(() => logger.err(any()));
      expect(
        context.vars,
        equals({
          'port': customPort,
          'directories': <RouteDirectory>[],
          'routes': <RouteFile>[],
          'middleware': <MiddlewareFile>[],
          'globalMiddleware': false,
          'serveStaticFiles': false,
          'invokeCustomEntrypoint': true,
        }),
      );
    });

    test('updates context.vars when buildRouteConfiguration succeeds',
        () async {
      const configuration = RouteConfiguration(
        globalMiddleware: MiddlewareFile(
          name: 'middleware',
          path: 'middleware.dart',
        ),
        middleware: [
          MiddlewareFile(
            name: 'hello_middleware',
            path: 'hello/middleware.dart',
          )
        ],
        directories: [
          RouteDirectory(
            name: '_',
            route: '/',
            middleware: null,
            files: [
              RouteFile(name: 'index', path: 'index.dart', route: '/'),
              RouteFile(name: 'hello', path: 'hello.dart', route: '/hello'),
            ],
          )
        ],
        routes: [
          RouteFile(name: 'index', path: 'index.dart', route: '/'),
          RouteFile(name: 'hello', path: 'hello.dart', route: '/hello'),
        ],
        endpoints: {
          '/': [
            RouteFile(name: 'index', path: 'index.dart', route: '/'),
          ],
          '/hello': [
            RouteFile(name: 'hello', path: 'hello.dart', route: '/hello'),
          ]
        },
        rogueRoutes: [],
        serveStaticFiles: true,
      );
      final exitCalls = <int>[];
      await preGen(
        context,
        buildConfiguration: (_) => configuration,
        exit: exitCalls.add,
      );
      expect(exitCalls, isEmpty);
      verifyNever(() => logger.err(any()));
      expect(
        context.vars,
        equals({
          'port': '8080',
          'directories': [
            {
              'name': '_',
              'route': '/',
              'middleware': false,
              'files': [
                {'name': 'index', 'path': 'index.dart', 'route': '/'},
                {'name': 'hello', 'path': 'hello.dart', 'route': '/hello'}
              ]
            }
          ],
          'routes': [
            {'name': 'index', 'path': 'index.dart', 'route': '/'},
            {'name': 'hello', 'path': 'hello.dart', 'route': '/hello'}
          ],
          'middleware': [
            {'name': 'hello_middleware', 'path': 'hello/middleware.dart'}
          ],
          'globalMiddleware': {'name': 'middleware', 'path': 'middleware.dart'},
          'serveStaticFiles': true,
          'invokeCustomEntrypoint': false,
        }),
      );
    });
  });

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
      when(() => configuration.endpoints).thenReturn({});
      reportRouteConflicts(context, configuration);
      verifyNever(() => logger.err(any()));
    });

    test('reports nothing when there are endpoints and no conflicts', () {
      when(() => configuration.endpoints).thenReturn({
        '/': const [
          RouteFile(name: 'index', path: 'index.dart', route: '/'),
        ],
        '/hello': const [
          RouteFile(name: 'hello', path: 'hello.dart', route: '/hello')
        ]
      });
      reportRouteConflicts(context, configuration);
      verifyNever(() => logger.err(any()));
    });

    test('reports single conflict when there is one endpoint with conflicts',
        () {
      when(() => configuration.endpoints).thenReturn({
        '/': const [
          RouteFile(name: 'index', path: 'index.dart', route: '/'),
        ],
        '/hello': const [
          RouteFile(name: 'hello', path: 'hello.dart', route: '/hello'),
          RouteFile(name: 'hello_index', path: 'hello/index.dart', route: '/')
        ]
      });
      reportRouteConflicts(context, configuration);
      verify(
        () => logger.err(
          '''Route conflict detected. ${lightCyan.wrap('routes/hello.dart')} and ${lightCyan.wrap('routes/hello/index.dart')} both resolve to ${lightCyan.wrap('/hello')}.''',
        ),
      );
    });

    test(
        'reports multiple conflicts '
        'when there are multiple endpoint with conflicts', () {
      when(() => configuration.endpoints).thenReturn({
        '/': const [
          RouteFile(name: 'index', path: 'index.dart', route: '/'),
        ],
        '/hello': const [
          RouteFile(name: 'hello', path: 'hello.dart', route: '/hello'),
          RouteFile(name: 'hello_index', path: 'hello/index.dart', route: '/')
        ],
        '/echo': const [
          RouteFile(name: 'echo', path: 'echo.dart', route: '/echo'),
          RouteFile(name: 'echo_index', path: 'echo/index.dart', route: '/')
        ]
      });
      reportRouteConflicts(context, configuration);
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
    });
  });

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
      when(() => configuration.rogueRoutes).thenReturn([]);
      reportRogueRoutes(context, configuration);
      verifyNever(() => logger.err(any()));
    });

    test('reports single rogue route', () {
      when(() => configuration.rogueRoutes).thenReturn(
        const [
          RouteFile(name: 'hello', path: 'hello.dart', route: '/hello'),
        ],
      );
      reportRogueRoutes(context, configuration);
      verify(
        () => logger.err(
          '''Rogue route detected.${defaultForeground.wrap(' ')}Rename ${lightCyan.wrap('routes/hello.dart')} to ${lightCyan.wrap('routes/hello/index.dart')}.''',
        ),
      );
    });

    test('reports multiple rogue routes', () {
      when(() => configuration.rogueRoutes).thenReturn(
        const [
          RouteFile(name: 'hello', path: 'hello.dart', route: '/hello'),
          RouteFile(name: 'hi', path: 'hi.dart', route: '/hi'),
        ],
      );
      reportRogueRoutes(context, configuration);
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
    });
  });

  group('ExitOverrides', () {
    group('runZoned', () {
      test('uses default exit when not specified', () {
        ExitOverrides.runZoned(() {
          final overrides = ExitOverrides.current;
          expect(overrides!.exit, equals(exit));
        });
      });

      test('uses custom exit when specified', () {
        ExitOverrides.runZoned(
          () {
            final overrides = ExitOverrides.current;
            expect(overrides!.exit, isNot(equals(exit)));
          },
          exit: (_) {},
        );
      });
    });
  });
}
