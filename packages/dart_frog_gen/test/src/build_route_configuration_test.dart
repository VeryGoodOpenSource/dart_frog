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

    test('invokeCustomEntrypoint is true when main.dart exists', () {
      final directory = Directory.systemTemp.createTempSync();
      Directory(path.join(directory.path, 'routes')).createSync();
      File(path.join(directory.path, 'main.dart')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(configuration.invokeCustomEntrypoint, isTrue);
    });

    test('invokeCustomEntrypoint is false when main.dart does not exist', () {
      final directory = Directory.systemTemp.createTempSync();
      Directory(path.join(directory.path, 'routes')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(configuration.invokeCustomEntrypoint, isFalse);
    });

    test('includes global middleware when it exists', () {
      final directory = Directory.systemTemp.createTempSync();
      final routes = Directory(path.join(directory.path, 'routes'))
        ..createSync();
      File(path.join(routes.path, '_middleware.dart')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(configuration.globalMiddleware, isNotNull);
    });

    test('endpoint includes multiple routes when conflicts exist', () {
      final directory = Directory(
        path.join(
          Directory.current.path,
          'test',
          '.fixtures',
          'single_conflict',
        ),
      )..createSync(recursive: true);
      final routes = Directory(path.join(directory.path, 'routes'))
        ..createSync();
      File(path.join(routes.path, 'users.dart')).createSync();
      final usersDirectory = Directory(path.join(routes.path, 'users'))
        ..createSync();
      File(path.join(usersDirectory.path, 'index.dart')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(
        configuration.endpoints,
        equals({
          '/users': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/users.dart',
            ),
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/users/index.dart',
            )
          ]
        }),
      );
    });

    test('includes single index route', () {
      const expected = [
        {
          'name': '_',
          'route': '/',
          'middleware': false,
          'files': [
            {'name': 'index', 'path': '../routes/index.dart', 'route': '/'}
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
      expect(
        configuration.endpoints,
        equals({
          '/': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/index.dart',
            )
          ]
        }),
      );
    });

    test('includes multiple top-level routes', () {
      const expected = [
        {
          'name': '_',
          'route': '/',
          'middleware': false,
          'files': [
            {'name': 'index', 'path': '../routes/index.dart', 'route': '/'},
            {'name': 'hello', 'path': '../routes/hello.dart', 'route': '/hello'}
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
      expect(
        configuration.endpoints,
        equals({
          '/': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/index.dart',
            )
          ],
          '/hello': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/hello.dart',
            )
          ]
        }),
      );
    });

    test('includes nested routes', () {
      const expected = [
        {
          'name': '_',
          'route': '/',
          'middleware': false,
          'files': [
            {'name': 'index', 'path': '../routes/index.dart', 'route': '/'}
          ]
        },
        {
          'name': '_echo',
          'route': '/echo',
          'middleware': false,
          'files': [
            {
              'name': 'echo_message',
              'path': '../routes/echo/message.dart',
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
      expect(
        configuration.endpoints,
        equals({
          '/': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/index.dart',
            )
          ],
          '/echo/message': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/echo/message.dart',
            )
          ]
        }),
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
              'name': 'echo_message_index',
              'path': '../routes/echo/message/index.dart',
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
      expect(
        configuration.endpoints,
        equals({
          '/echo/message': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/echo/message/index.dart',
            )
          ]
        }),
      );
    });

    test('includes dynamic route', () {
      const expected = [
        {
          'name': '_',
          'route': '/',
          'middleware': false,
          'files': [
            {'name': 'index', 'path': '../routes/index.dart', 'route': '/'}
          ]
        },
        {
          'name': '_echo',
          'route': '/echo',
          'middleware': false,
          'files': [
            {
              'name': r'echo_$message',
              'path': '../routes/echo/[message].dart',
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
      expect(
        configuration.endpoints,
        equals({
          '/': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/index.dart',
            )
          ],
          '/echo/<message>': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/echo/[message].dart',
            )
          ]
        }),
      );
    });

    test('includes dynamic nested directory routes', () {
      const expected = [
        {
          'name': '_',
          'route': '/',
          'middleware': false,
          'files': [
            {'name': 'index', 'path': '../routes/index.dart', 'route': '/'},
            {
              'name': r'$user_$name',
              'path': '../routes/[user]/[name].dart',
              'route': '/<user>/<name>'
            },
            {
              'name': r'$user_$id_index',
              'path': '../routes/[user]/[id]/index.dart',
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
      expect(
        configuration.endpoints,
        equals({
          '/': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/index.dart',
            )
          ],
          '/<user>/<name>': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/[user]/[name].dart',
            )
          ],
          '/<user>/<id>': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/[user]/[id]/index.dart',
            )
          ]
        }),
      );
    });

    test('supports /[id]/api/index.dart', () {
      const expected = [
        {
          'name': '_',
          'route': '/',
          'middleware': false,
          'files': [
            {'name': 'index', 'path': '../routes/index.dart', 'route': '/'},
            {
              'name': r'$id_api_index',
              'path': '../routes/[id]/api/index.dart',
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
      expect(
        configuration.endpoints,
        equals({
          '/': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/index.dart',
            )
          ],
          '/<id>/api': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/[id]/api/index.dart',
            )
          ],
        }),
      );
    });

    test('supports /[id]/api/test.dart', () {
      const expected = [
        {
          'name': '_',
          'route': '/',
          'middleware': false,
          'files': [
            {'name': 'index', 'path': '../routes/index.dart', 'route': '/'},
            {
              'name': r'$id_api_test',
              'path': '../routes/[id]/api/test.dart',
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
      expect(
        configuration.endpoints,
        equals({
          '/': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/index.dart',
            )
          ],
          '/<id>/api/test': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/[id]/api/test.dart',
            )
          ],
        }),
      );
    });

    test('supports /[id]/api/[name]/index.dart', () {
      const expected = [
        {
          'name': '_',
          'route': '/',
          'middleware': false,
          'files': [
            {'name': 'index', 'path': '../routes/index.dart', 'route': '/'},
            {
              'name': r'$id_api_$name_index',
              'path': '../routes/[id]/api/[name]/index.dart',
              'route': '/<id>/api/<name>'
            }
          ]
        }
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
      expect(
        configuration.endpoints,
        equals({
          '/': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/index.dart',
            )
          ],
          '/<id>/api/<name>': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/[id]/api/[name]/index.dart',
            )
          ],
        }),
      );
    });

    test('supports /[id]/api/[name]/test.dart', () {
      const expected = [
        {
          'name': '_',
          'route': '/',
          'middleware': false,
          'files': [
            {'name': 'index', 'path': '../routes/index.dart', 'route': '/'},
            {
              'name': r'$id_api_$name_test',
              'path': '../routes/[id]/api/[name]/test.dart',
              'route': '/<id>/api/<name>/test'
            }
          ]
        }
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
      expect(
        configuration.endpoints,
        equals({
          '/': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/index.dart',
            )
          ],
          '/<id>/api/<name>/test': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/[id]/api/[name]/test.dart',
            )
          ],
        }),
      );
    });

    test('supports /api/api.dart', () {
      const expected = [
        {'name': '_', 'route': '/', 'middleware': false, 'files': <dynamic>[]},
        {
          'name': '_api',
          'route': '/api',
          'middleware': false,
          'files': [
            {
              'name': 'api_api',
              'path': '../routes/api/api.dart',
              'route': '/api'
            }
          ]
        }
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
      final apiDirectory = Directory(path.join(routes.path, 'api'))
        ..createSync();
      File(path.join(apiDirectory.path, 'api.dart')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(
        configuration.directories.map((d) => d.toJson()).toList(),
        equals(expected),
      );
      expect(
        configuration.endpoints,
        equals({
          '/api/api': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/api/api.dart',
            )
          ],
        }),
      );
    });

    test('detects rogue routes.', () {
      const expected = [
        {
          'name': '_',
          'route': '/',
          'middleware': false,
          'files': [
            {'name': 'api', 'path': '../routes/api.dart', 'route': '/api'}
          ]
        },
        {
          'name': '_api',
          'route': '/api',
          'middleware': false,
          'files': [
            {'name': 'api_v1', 'path': '../routes/api/v1.dart', 'route': '/v1'},
            {
              'name': r'api_$id',
              'path': '../routes/api/[id].dart',
              'route': '/<id>'
            }
          ]
        },
        {
          'name': '_api_v1',
          'route': '/api/v1',
          'middleware': false,
          'files': [
            {
              'name': 'api_v1_hello',
              'path': '../routes/api/v1/hello.dart',
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
          'rogue_routes',
        ),
      )..createSync(recursive: true);
      final routes = Directory(path.join(directory.path, 'routes'))
        ..createSync();
      File(path.join(routes.path, 'api.dart')).createSync();
      final apiDirectory = Directory(path.join(routes.path, 'api'))
        ..createSync();
      File(path.join(apiDirectory.path, '[id].dart')).createSync();
      File(path.join(apiDirectory.path, 'v1.dart')).createSync();
      final v1Directory = Directory(path.join(apiDirectory.path, 'v1'))
        ..createSync();
      File(path.join(v1Directory.path, 'hello.dart')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(
        configuration.directories.map((d) => d.toJson()).toList(),
        equals(expected),
      );
      expect(
        configuration.endpoints,
        equals({
          '/api': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/api.dart',
            )
          ],
          '/api/v1': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/api/v1.dart',
            )
          ],
          '/api/<id>': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/api/[id].dart',
            )
          ],
          '/api/v1/hello': [
            isA<RouteFile>().having(
              (r) => r.path,
              'path',
              '../routes/api/v1/hello.dart',
            )
          ],
        }),
      );
      expect(
        configuration.rogueRoutes,
        equals([
          isA<RouteFile>().having(
            (r) => r.path,
            'path',
            '../routes/api.dart',
          ),
          isA<RouteFile>().having(
            (r) => r.path,
            'path',
            '../routes/api/v1.dart',
          )
        ]),
      );
    });
  });
}
