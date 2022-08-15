import 'dart:io';

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason/mason.dart'
    show HookContext, Logger, Progress, defaultForeground, lightCyan;
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../pre_gen.dart';

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

class _MockHookContext extends Mock implements HookContext {}

class _MockLogger extends Mock implements Logger {}

class _MockProgress extends Mock implements Progress {}

class _MockRouteConfiguration extends Mock implements RouteConfiguration {}

void main() {
  group('preGen', () {
    late HookContext context;
    late Logger logger;

    setUp(() {
      logger = _MockLogger();
      context = _FakeHookContext(logger: logger);

      when(() => logger.progress(any())).thenReturn(_MockProgress());
    });

    test('run completes', () {
      expect(
        ExitOverrides.runZoned(
          () => run(_FakeHookContext(logger: logger)),
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
          'directories': <RouteDirectory>[],
          'routes': <RouteFile>[],
          'middleware': <MiddlewareFile>[],
          'globalMiddleware': false,
          'invokeCustomEntrypoint': true,
          'pathDependencies': <String>[]
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
        rogueRoutes: [],
        endpoints: {
          '/': [
            RouteFile(name: 'index', path: 'index.dart', route: '/'),
          ],
          '/hello': [
            RouteFile(name: 'hello', path: 'hello.dart', route: '/hello'),
          ]
        },
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
          'invokeCustomEntrypoint': false,
          'pathDependencies': <String>[],
        }),
      );
    });

    group('createBundle', () {
      test('exit(1) if bundling throws', () async {
        final exitCalls = <int>[];
        await createBundle(context, Directory('/invalid/dir'), exitCalls.add);
        expect(exitCalls, equals([1]));
        verify(() => logger.err(any())).called(1);
      });

      test('does not throw when bundling succeeds', () async {
        final exitCalls = <int>[];
        final directory = Directory.systemTemp.createTempSync();
        final dotDartFrogDir =
            Directory(path.join(directory.path, '.dart_frog'))..createSync();
        final buildDir = Directory(path.join(directory.path, 'build'))
          ..createSync();
        final oldBuildArtifact = File(path.join(buildDir.path, 'artifact.txt'))
          ..createSync();
        await createBundle(context, directory, exitCalls.add);
        expect(dotDartFrogDir.existsSync(), isFalse);
        expect(buildDir.existsSync(), isTrue);
        expect(oldBuildArtifact.existsSync(), isFalse);
        expect(exitCalls, isEmpty);
        verifyNever(() => logger.err(any()));
      });
    });

    group('getPathDependencies', () {
      test('returns nothing when there are no path dependencies', () {
        final directory = Directory.systemTemp.createTempSync();
        File(path.join(directory.path, 'pubspec.yaml')).writeAsStringSync(
          '''
name: example
version: 0.1.0
environment:
  sdk: ^2.17.0
dependencies:
  mason: any
dev_dependencies:
  test: any
''',
        );
        expect(getPathDependencies(directory), completion(isEmpty));
        directory.delete(recursive: true).ignore();
      });

      test('returns correct path dependencies', () {
        final directory = Directory.systemTemp.createTempSync();
        File(path.join(directory.path, 'pubspec.yaml')).writeAsStringSync(
          '''
name: example
version: 0.1.0
environment:
  sdk: ^2.17.0
dependencies:
  mason: any
  dart_frog:
    path: ./path/to/dart_frog
dev_dependencies:
  test: any
  dart_frog_gen:
    path: ./path/to/dart_frog_gen  
''',
        );
        expect(
          getPathDependencies(directory),
          completion(
            equals(['./path/to/dart_frog', './path/to/dart_frog_gen']),
          ),
        );
        directory.delete(recursive: true).ignore();
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
            RouteFile(name: 'index', path: 'index.dart', route: '/'),
          ],
          '/hello': const [
            RouteFile(name: 'hello', path: 'hello.dart', route: '/hello')
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
            RouteFile(name: 'index', path: 'index.dart', route: '/'),
          ],
          '/hello': const [
            RouteFile(name: 'hello', path: 'hello.dart', route: '/hello'),
            RouteFile(name: 'hello_index', path: 'hello/index.dart', route: '/')
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
            RouteFile(name: 'hello', path: 'hello.dart', route: '/hello'),
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
            RouteFile(name: 'hello', path: 'hello.dart', route: '/hello'),
            RouteFile(name: 'hi', path: 'hi.dart', route: '/hi'),
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
