import 'dart:io';

import 'package:dart_frog_gen/src/build_route_configuration.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('buildRouteConfiguration', () {
    tearDown(() {
      try {
        Directory(
          path.join(Directory.current.path, 'test', '.fixtures'),
        ).deleteSync(recursive: true);
      } catch (_) {}
    });

    test('throws exception when routes directory does not exist', () {
      expect(() => buildRouteConfiguration(Directory.current), throwsException);
    });

    test('excludes global middleware when it does not exist', () {
      final directory = Directory.systemTemp.createTempSync();
      Directory(path.join(directory.path, 'routes')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(configuration.globalMiddleware, isNull);
    });

    test('serveStaticFiles is true when public directory exists', () {
      final directory = Directory.systemTemp.createTempSync();
      Directory(path.join(directory.path, 'routes')).createSync();
      Directory(path.join(directory.path, 'public')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(configuration.serveStaticFiles, isTrue);
    });

    test('serveStaticFiles is false when public directory does not exist', () {
      final directory = Directory.systemTemp.createTempSync();
      Directory(path.join(directory.path, 'routes')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(configuration.serveStaticFiles, isFalse);
    });

    test('includes global middleware when it exists', () {
      final directory = Directory.systemTemp.createTempSync();
      final routes = Directory(path.join(directory.path, 'routes'))
        ..createSync();
      File(path.join(routes.path, '_middleware.dart')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(configuration.globalMiddleware, isNotNull);
    });

    test('includes single index route', () {
      const expected = [
        {
          'name': '_',
          'route': '/',
          'middleware': false,
          'files': [
            {
              'name': '.._test_.fixtures_single_routes_index',
              'path': '../test/.fixtures/single/routes/index.dart',
              'route': '/routes'
            }
          ]
        }
      ];
      final directory = Directory(
        path.join(Directory.current.path, 'test', '.fixtures', 'single'),
      )..createSync(recursive: true);
      final routes = Directory(path.join(directory.path, 'routes'))
        ..createSync();
      File(path.join(routes.path, 'index.dart')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(
        configuration.directories.map((d) => d.toJson()).toList(),
        equals(expected),
      );
    });

    test('includes multiple top-level routes', () {
      const expected = [
        {
          'name': '_',
          'route': '/',
          'middleware': false,
          'files': [
            {
              'name': '.._test_.fixtures_multiple_top_level_routes_index',
              'path': '../test/.fixtures/multiple_top_level/routes/index.dart',
              'route': '/routes'
            },
            {
              'name': '.._test_.fixtures_multiple_top_level_routes_hello',
              'path': '../test/.fixtures/multiple_top_level/routes/hello.dart',
              'route': '/hello'
            }
          ]
        }
      ];
      final directory = Directory(
        path.join(
          Directory.current.path,
          'test',
          '.fixtures',
          'multiple_top_level',
        ),
      )..createSync(recursive: true);
      final routes = Directory(path.join(directory.path, 'routes'))
        ..createSync();
      File(path.join(routes.path, 'index.dart')).createSync();
      File(path.join(routes.path, 'hello.dart')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(
        configuration.directories.map((d) => d.toJson()).toList(),
        equals(expected),
      );
    });

    test('includes nested routes', () {
      const expected = [
        {
          'name': '_',
          'route': '/',
          'middleware': false,
          'files': [
            {
              'name': '.._test_.fixtures_nested_routes_index',
              'path': '../test/.fixtures/nested/routes/index.dart',
              'route': '/routes'
            }
          ]
        },
        {
          'name': '_echo',
          'route': '/echo',
          'middleware': false,
          'files': [
            {
              'name': '.._test_.fixtures_nested_routes_echo_message',
              'path': '../test/.fixtures/nested/routes/echo/message.dart',
              'route': '/message'
            }
          ]
        }
      ];
      final directory = Directory(
        path.join(Directory.current.path, 'test', '.fixtures', 'nested'),
      )..createSync(recursive: true);
      final routes = Directory(path.join(directory.path, 'routes'))
        ..createSync();
      File(path.join(routes.path, 'index.dart')).createSync();
      final echoDirectory = Directory(path.join(routes.path, 'echo'))
        ..createSync();
      File(path.join(echoDirectory.path, 'message.dart')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(
        configuration.directories.map((d) => d.toJson()).toList(),
        equals(expected),
      );
    });

    test('includes nested directories', () {
      const expected = [
        {'name': '_', 'route': '/', 'middleware': false, 'files': <dynamic>[]},
        {
          'name': '_echo',
          'route': '/echo',
          'middleware': false,
          'files': <dynamic>[]
        },
        {
          'name': '_echo_message',
          'route': '/echo/message',
          'middleware': false,
          'files': [
            {
              'name':
                  '''.._test_.fixtures_nested_directories_routes_echo_message_index''',
              'path':
                  '../test/.fixtures/nested_directories/routes/echo/message/index.dart',
              'route': '/'
            }
          ]
        }
      ];
      final directory = Directory(
        path.join(
          Directory.current.path,
          'test',
          '.fixtures',
          'nested_directories',
        ),
      )..createSync(recursive: true);
      final routes = Directory(path.join(directory.path, 'routes'))
        ..createSync();
      final echoDirectory = Directory(path.join(routes.path, 'echo'))
        ..createSync();
      final messageDirectory =
          Directory(path.join(echoDirectory.path, 'message'))..createSync();
      File(path.join(messageDirectory.path, 'index.dart')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(
        configuration.directories.map((d) => d.toJson()).toList(),
        equals(expected),
      );
    });

    test('includes dynamic route', () {
      const expected = [
        {
          'name': '_',
          'route': '/',
          'middleware': false,
          'files': [
            {
              'name': '.._test_.fixtures_dynamic_routes_index',
              'path': '../test/.fixtures/dynamic/routes/index.dart',
              'route': '/routes'
            }
          ]
        },
        {
          'name': '_echo',
          'route': '/echo',
          'middleware': false,
          'files': [
            {
              'name': r'.._test_.fixtures_dynamic_routes_echo_$message',
              'path': '../test/.fixtures/dynamic/routes/echo/[message].dart',
              'route': '/<message>'
            }
          ]
        }
      ];
      final directory = Directory(
        path.join(Directory.current.path, 'test', '.fixtures', 'dynamic'),
      )..createSync(recursive: true);
      final routes = Directory(path.join(directory.path, 'routes'))
        ..createSync();
      File(path.join(routes.path, 'index.dart')).createSync();
      final echoDirectory = Directory(path.join(routes.path, 'echo'))
        ..createSync();
      File(path.join(echoDirectory.path, '[message].dart')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(
        configuration.directories.map((d) => d.toJson()).toList(),
        equals(expected),
      );
    });

    test('includes dynamic nested directory routes', () {
      const expected = [
        {
          'name': '_',
          'route': '/',
          'middleware': false,
          'files': [
            {
              'name': '.._test_.fixtures_dynamic_nested_routes_index',
              'path': '../test/.fixtures/dynamic_nested/routes/index.dart',
              'route': '/routes'
            },
            {
              'name': r'.._test_.fixtures_dynamic_nested_routes_$user_$name',
              'path':
                  '../test/.fixtures/dynamic_nested/routes/[user]/[name].dart',
              'route': '/<user>/<name>'
            },
            {
              'name':
                  r'.._test_.fixtures_dynamic_nested_routes_$user_$id_index',
              'path':
                  '../test/.fixtures/dynamic_nested/routes/[user]/[id]/index.dart',
              'route': '/<user>/<id>'
            }
          ]
        }
      ];
      final directory = Directory(
        path.join(
          Directory.current.path,
          'test',
          '.fixtures',
          'dynamic_nested',
        ),
      )..createSync(recursive: true);
      final routes = Directory(path.join(directory.path, 'routes'))
        ..createSync();
      File(path.join(routes.path, 'index.dart')).createSync();
      final userDirectory = Directory(path.join(routes.path, '[user]'))
        ..createSync();
      File(path.join(userDirectory.path, '[name].dart')).createSync();
      final idDirectory = Directory(path.join(userDirectory.path, '[id]'))
        ..createSync();
      File(path.join(idDirectory.path, 'index.dart')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(
        configuration.directories.map((d) => d.toJson()).toList(),
        equals(expected),
      );
    });

    test('supports /[id]/api/index.dart', () {
      const expected = [
        {
          'name': '_',
          'route': '/',
          'middleware': false,
          'files': [
            {
              'name': '.._test_.fixtures_dynamic_static_nesting1_routes_index',
              'path':
                  '../test/.fixtures/dynamic_static_nesting1/routes/index.dart',
              'route': '/routes'
            },
            {
              'name':
                  r'''.._test_.fixtures_dynamic_static_nesting1_routes_$id_api_index''',
              'path':
                  '../test/.fixtures/dynamic_static_nesting1/routes/[id]/api/index.dart',
              'route': '/<id>/api'
            }
          ]
        }
      ];
      final directory = Directory(
        path.join(
          Directory.current.path,
          'test',
          '.fixtures',
          'dynamic_static_nesting1',
        ),
      )..createSync(recursive: true);
      final routes = Directory(path.join(directory.path, 'routes'))
        ..createSync();
      File(path.join(routes.path, 'index.dart')).createSync();
      final idDirectory = Directory(path.join(routes.path, '[id]'))
        ..createSync();
      final apiDirectory = Directory(path.join(idDirectory.path, 'api'))
        ..createSync();
      File(path.join(apiDirectory.path, 'index.dart')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(
        configuration.directories.map((d) => d.toJson()).toList(),
        equals(expected),
      );
    });

    test('supports /[id]/api/test.dart', () {
      const expected = [
        {
          'name': '_',
          'route': '/',
          'middleware': false,
          'files': [
            {
              'name': '.._test_.fixtures_dynamic_static_nesting2_routes_index',
              'path':
                  '../test/.fixtures/dynamic_static_nesting2/routes/index.dart',
              'route': '/routes'
            },
            {
              'name':
                  r'''.._test_.fixtures_dynamic_static_nesting2_routes_$id_api_test''',
              'path':
                  '../test/.fixtures/dynamic_static_nesting2/routes/[id]/api/test.dart',
              'route': '/<id>/api/test'
            }
          ]
        }
      ];
      final directory = Directory(
        path.join(
          Directory.current.path,
          'test',
          '.fixtures',
          'dynamic_static_nesting2',
        ),
      )..createSync(recursive: true);
      final routes = Directory(path.join(directory.path, 'routes'))
        ..createSync();
      File(path.join(routes.path, 'index.dart')).createSync();
      final idDirectory = Directory(path.join(routes.path, '[id]'))
        ..createSync();
      final apiDirectory = Directory(path.join(idDirectory.path, 'api'))
        ..createSync();
      File(path.join(apiDirectory.path, 'test.dart')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(
        configuration.directories.map((d) => d.toJson()).toList(),
        equals(expected),
      );
    });

    test('supports /[id]/api/[name]/index.dart', () {
      const expected = [
        {
          'name': '_',
          'route': '/',
          'middleware': false,
          'files': [
            {
              'name': '.._test_.fixtures_dynamic_static_nesting3_routes_index',
              'path':
                  '../test/.fixtures/dynamic_static_nesting3/routes/index.dart',
              'route': '/routes'
            },
            {
              'name':
                  r'''.._test_.fixtures_dynamic_static_nesting3_routes_$id_api_$name_index''',
              'path':
                  '../test/.fixtures/dynamic_static_nesting3/routes/[id]/api/[name]/index.dart',
              'route': '/<id>/api/<name>'
            }
          ]
        },
      ];
      final directory = Directory(
        path.join(
          Directory.current.path,
          'test',
          '.fixtures',
          'dynamic_static_nesting3',
        ),
      )..createSync(recursive: true);
      final routes = Directory(path.join(directory.path, 'routes'))
        ..createSync();
      File(path.join(routes.path, 'index.dart')).createSync();
      final idDirectory = Directory(path.join(routes.path, '[id]'))
        ..createSync();
      final apiDirectory = Directory(path.join(idDirectory.path, 'api'))
        ..createSync();
      final nameDirectory = Directory(path.join(apiDirectory.path, '[name]'))
        ..createSync();
      File(path.join(nameDirectory.path, 'index.dart')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(
        configuration.directories.map((d) => d.toJson()).toList(),
        equals(expected),
      );
    });

    test('supports /[id]/api/[name]/test.dart', () {
      const expected = [
        {
          'name': '_',
          'route': '/',
          'middleware': false,
          'files': [
            {
              'name': '.._test_.fixtures_dynamic_static_nesting4_routes_index',
              'path':
                  '../test/.fixtures/dynamic_static_nesting4/routes/index.dart',
              'route': '/routes'
            },
            {
              'name':
                  r'''.._test_.fixtures_dynamic_static_nesting4_routes_$id_api_$name_test''',
              'path':
                  '../test/.fixtures/dynamic_static_nesting4/routes/[id]/api/[name]/test.dart',
              'route': '/<id>/api/<name>/test'
            }
          ]
        },
      ];
      final directory = Directory(
        path.join(
          Directory.current.path,
          'test',
          '.fixtures',
          'dynamic_static_nesting4',
        ),
      )..createSync(recursive: true);
      final routes = Directory(path.join(directory.path, 'routes'))
        ..createSync();
      File(path.join(routes.path, 'index.dart')).createSync();
      final idDirectory = Directory(path.join(routes.path, '[id]'))
        ..createSync();
      final apiDirectory = Directory(path.join(idDirectory.path, 'api'))
        ..createSync();
      final nameDirectory = Directory(path.join(apiDirectory.path, '[name]'))
        ..createSync();
      File(path.join(nameDirectory.path, 'test.dart')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(
        configuration.directories.map((d) => d.toJson()).toList(),
        equals(expected),
      );
    });
  });
}
