import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason/mason.dart' show HookContext, Logger, Progress;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../pre_gen.dart';
import '../src/exit_overrides.dart';

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

class _MockProgress extends Mock implements Progress {}

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
          'serveStaticFiles': false,
          'invokeCustomEntrypoint': true,
          'invokeCustomInit': false,
          'pathDependencies': <String>[]
        }),
      );
    });

    test('retains invokeCustomInit (true)', () async {
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
          'serveStaticFiles': false,
          'invokeCustomEntrypoint': false,
          'invokeCustomInit': true,
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
            middleware: [],
            files: [
              RouteFile(
                name: 'index',
                path: 'index.dart',
                route: '/',
                params: [],
              ),
              RouteFile(
                name: 'hello',
                path: 'hello.dart',
                route: '/hello',
                params: [],
              ),
            ],
            params: [],
          )
        ],
        routes: [
          RouteFile(
            name: 'index',
            path: 'index.dart',
            route: '/',
            params: [],
          ),
          RouteFile(
            name: 'hello',
            path: 'hello.dart',
            route: '/hello',
            params: [],
          ),
        ],
        rogueRoutes: [],
        endpoints: {
          '/': [
            RouteFile(
              name: 'index',
              path: 'index.dart',
              route: '/',
              params: [],
            ),
          ],
          '/hello': [
            RouteFile(
              name: 'hello',
              path: 'hello.dart',
              route: '/hello',
              params: [],
            ),
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
              'middleware': <Map<String, dynamic>>[],
              'files': [
                {
                  'name': 'index',
                  'path': 'index.dart',
                  'route': '/',
                  'file_params': const <String>[]
                },
                {
                  'name': 'hello',
                  'path': 'hello.dart',
                  'route': '/hello',
                  'file_params': const <String>[]
                }
              ],
              'directory_params': const <String>[],
            }
          ],
          'routes': [
            {
              'name': 'index',
              'path': 'index.dart',
              'route': '/',
              'file_params': const <String>[]
            },
            {
              'name': 'hello',
              'path': 'hello.dart',
              'route': '/hello',
              'file_params': const <String>[]
            }
          ],
          'middleware': [
            {'name': 'hello_middleware', 'path': 'hello/middleware.dart'}
          ],
          'globalMiddleware': {'name': 'middleware', 'path': 'middleware.dart'},
          'serveStaticFiles': true,
          'invokeCustomEntrypoint': false,
          'invokeCustomInit': false,
          'pathDependencies': <String>[],
        }),
      );
    });
  });
}
