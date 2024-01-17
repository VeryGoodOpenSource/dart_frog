import 'dart:io';

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:dart_frog_prod_server_hooks/dart_frog_prod_server_hooks.dart';
import 'package:mason/mason.dart'
    show HookContext, Logger, Progress, defaultForeground, lightCyan;
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../pre_gen.dart' as pre_gen;
import 'pubspec_locks.dart';

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

    Future<ProcessResult> successRunProcess(
      executable,
      args, {
      String? workingDirectory,
      bool? runInShell,
    }) =>
        Future.value(ProcessResult(0, 0, '', ''));

    setUp(() {
      logger = _MockLogger();
      context = _FakeHookContext(logger: logger)
        ..vars['dartVersion'] = 'stable';

      when(() => logger.progress(any())).thenReturn(_MockProgress());
    });

    test('run completes', () {
      expect(
        ExitOverrides.runZoned(
          () => pre_gen.run(_FakeHookContext(logger: logger)),
          exit: (_) {},
        ),
        completes,
      );
    });

    test('exit(1) if buildRouteConfiguration throws', () async {
      final exitCalls = <int>[];
      final exception = Exception('oops');
      await pre_gen.preGen(
        context,
        buildConfiguration: (_) => throw exception,
        exit: exitCalls.add,
        runProcess: successRunProcess,
      );
      expect(exitCalls, equals([1]));
      verify(() => logger.err(exception.toString())).called(1);
    });

    test('exit(1) for route conflicts', () async {
      const configuration = RouteConfiguration(
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

      final exitCalls = <int>[];
      await pre_gen.preGen(
        context,
        buildConfiguration: (_) => configuration,
        exit: exitCalls.add,
        runProcess: successRunProcess,
      );

      verify(
        () => logger.err(
          '''Route conflict detected. ${lightCyan.wrap('routes/hello.dart')} and ${lightCyan.wrap('routes/hello/index.dart')} both resolve to ${lightCyan.wrap('/hello')}.''',
        ),
      );
      expect(exitCalls, equals([1]));
    });

    test('exit(1) for rogue routes', () async {
      const configuration = RouteConfiguration(
        middleware: [],
        directories: [],
        routes: [],
        rogueRoutes: [
          RouteFile(
            name: 'hello',
            path: 'hello.dart',
            route: '/hello',
            params: [],
            wildcard: false,
          ),
        ],
        endpoints: {},
        invokeCustomEntrypoint: true,
      );

      final exitCalls = <int>[];
      await pre_gen.preGen(
        context,
        buildConfiguration: (_) => configuration,
        exit: exitCalls.add,
        runProcess: successRunProcess,
      );

      verify(
        () => logger.err(
          '''Rogue route detected.${defaultForeground.wrap(' ')}Rename ${lightCyan.wrap('routes/hello.dart')} to ${lightCyan.wrap('routes/hello/index.dart')}.''',
        ),
      );
      expect(exitCalls, equals([1]));
    });

    test(
      'works with external dependencies',
      () async {
        const configuration = RouteConfiguration(
          middleware: [],
          directories: [],
          routes: [],
          rogueRoutes: [],
          endpoints: {},
        );

        final directory = Directory.systemTemp.createTempSync();
        File(path.join(directory.path, 'pubspec.yaml')).writeAsStringSync(
          '''
name: example
version: 0.1.0
environment:
  sdk: ^2.17.0
dependencies:
  mason: any
  foo:
    path: ../../foo
dev_dependencies:
  test: any
''',
        );
        File(path.join(directory.path, 'pubspec.lock')).writeAsStringSync(
          fooPath,
        );
        final exitCalls = <int>[];
        await pre_gen.preGen(
          context,
          buildConfiguration: (_) => configuration,
          exit: exitCalls.add,
          directory: directory,
          runProcess: successRunProcess,
          copyPath: (_, __) async {},
        );

        expect(exitCalls, isEmpty);
        directory.delete(recursive: true).ignore();
      },
    );

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
      await pre_gen.preGen(
        context,
        buildConfiguration: (_) => configuration,
        exit: exitCalls.add,
        runProcess: successRunProcess,
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
          'pathDependencies': <String>[],
          'hasExternalDependencies': false,
          'externalPathDependencies': <String>[],
          'dartVersion': 'stable',
          'addDockerfile': true,
        }),
      );
    });

    test("don't create the dockerfile if one already exists on the folder.",
        () async {
      const configuration = RouteConfiguration(
        middleware: [],
        directories: [],
        routes: [],
        rogueRoutes: [],
        endpoints: {},
      );

      final directory = Directory.systemTemp.createTempSync();
      File(path.join(directory.path, 'pubspec.yaml')).writeAsStringSync(
        '''
name: example
version: 0.1.0
environment:
  sdk: ^2.17.0
dependencies:
  mason: any
  test: any
''',
      );

      File(path.join(directory.path, 'pubspec.lock')).writeAsStringSync(
        noPathDependencies,
      );
      File(path.join(directory.path, 'Dockerfile')).writeAsStringSync(
        '',
      );

      final exitCalls = <int>[];
      await pre_gen.preGen(
        context,
        buildConfiguration: (_) => configuration,
        exit: exitCalls.add,
        directory: directory,
        runProcess: successRunProcess,
      );

      expect(
        context.vars,
        equals({
          'directories': <RouteDirectory>[],
          'routes': <RouteFile>[],
          'middleware': <MiddlewareFile>[],
          'globalMiddleware': false,
          'serveStaticFiles': false,
          'invokeCustomEntrypoint': false,
          'invokeCustomInit': false,
          'hasExternalDependencies': false,
          'externalPathDependencies': <String>[],
          'pathDependencies': <String>[],
          'dartVersion': 'stable',
          'addDockerfile': false,
        }),
      );
      directory.delete(recursive: true).ignore();
    });

    test('retains invokeCustomInit (true)', () async {
      const configuration = RouteConfiguration(
        middleware: [],
        directories: [],
        routes: [],
        rogueRoutes: [],
        endpoints: {},
        invokeCustomInit: true,
      );
      final exitCalls = <int>[];
      await pre_gen.preGen(
        context,
        buildConfiguration: (_) => configuration,
        exit: exitCalls.add,
        runProcess: successRunProcess,
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
          'hasExternalDependencies': false,
          'externalPathDependencies': <String>[],
          'pathDependencies': <String>[],
          'dartVersion': 'stable',
          'addDockerfile': true,
        }),
      );
    });

    test(
      'updates context.vars when buildRouteConfiguration succeeds',
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
            ),
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
                  wildcard: false,
                ),
                RouteFile(
                  name: 'hello',
                  path: 'hello.dart',
                  route: '/hello',
                  params: [],
                  wildcard: false,
                ),
              ],
              params: [],
            ),
          ],
          routes: [
            RouteFile(
              name: 'index',
              path: 'index.dart',
              route: '/',
              params: [],
              wildcard: false,
            ),
            RouteFile(
              name: 'hello',
              path: 'hello.dart',
              route: '/hello',
              params: [],
              wildcard: false,
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
            ],
          },
          serveStaticFiles: true,
        );
        final exitCalls = <int>[];
        await pre_gen.preGen(
          context,
          buildConfiguration: (_) => configuration,
          exit: exitCalls.add,
          runProcess: successRunProcess,
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
                    'file_params': const <String>[],
                    'wildcard': false,
                  },
                  {
                    'name': 'hello',
                    'path': 'hello.dart',
                    'route': '/hello',
                    'file_params': const <String>[],
                    'wildcard': false,
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
                'file_params': const <String>[],
                'wildcard': false,
              },
              {
                'name': 'hello',
                'path': 'hello.dart',
                'route': '/hello',
                'file_params': const <String>[],
                'wildcard': false,
              }
            ],
            'middleware': [
              {
                'name': 'hello_middleware',
                'path': 'hello/middleware.dart',
              },
            ],
            'globalMiddleware': {
              'name': 'middleware',
              'path': 'middleware.dart',
            },
            'serveStaticFiles': true,
            'invokeCustomEntrypoint': false,
            'invokeCustomInit': false,
            'hasExternalDependencies': false,
            'externalPathDependencies': <String>[],
            'pathDependencies': <String>[],
            'dartVersion': 'stable',
            'addDockerfile': true,
          }),
        );
      },
    );
  });
}
