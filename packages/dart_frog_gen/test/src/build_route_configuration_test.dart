import 'dart:io';

import 'package:dart_frog_gen/src/build_route_configuration.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  final cwd = Directory.current;
  group('buildRouteConfiguration', () {
    setUp(() {
      Directory.current = cwd;
    });

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
              'name': '.._routes_index',
              'path': '../routes/index.dart',
              'route': '/'
            }
          ]
        }
      ];
      final directory = Directory(
        path.join(Directory.current.path, 'test', '.fixtures', 'single'),
      )..createSync(recursive: true);
      final routes = Directory(path.join(directory.path, 'routes'))
        ..createSync();
      Directory.current = directory;
      File(path.join(routes.path, 'index.dart')).createSync();
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
              'name': '.._routes_index',
              'path': '../routes/index.dart',
              'route': '/'
            }
          ]
        },
        {
          'name': '_echo',
          'route': '/echo',
          'middleware': false,
          'files': [
            {
              'name': '.._routes_echo_message',
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
      Directory.current = directory;
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
        {
          'name': '_',
          'route': '/',
          'middleware': false,
          'files': [
            {
              'name': '.._routes_index',
              'path': '../routes/index.dart',
              'route': '/'
            }
          ]
        },
        {
          'name': '_echo',
          'route': '/echo',
          'middleware': false,
          'files': <RouteFile>[]
        },
        {
          'name': '_echo_message',
          'route': '/echo/message',
          'middleware': false,
          'files': [
            {
              'name': '.._routes_echo_message_index',
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
      Directory.current = directory;
      File(path.join(routes.path, 'index.dart')).createSync();
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
              'name': '.._routes_index',
              'path': '../routes/index.dart',
              'route': '/'
            }
          ]
        },
        {
          'name': '_echo',
          'route': '/echo',
          'middleware': false,
          'files': [
            {
              'name': r'.._routes_echo_$message',
              'path': '../routes/echo/<message>.dart',
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
      Directory.current = directory;
      File(path.join(routes.path, 'index.dart')).createSync();
      final echoDirectory = Directory(path.join(routes.path, 'echo'))
        ..createSync();
      File(path.join(echoDirectory.path, '<message>.dart')).createSync();
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
              'name': '.._routes_index',
              'path': '../routes/index.dart',
              'route': '/'
            },
            {
              'name': r'.._routes_$user_$name',
              'path': '../routes/<user>/<name>.dart',
              'route': '/<user>/<name>'
            },
            {
              'name': r'.._routes_$user_$id_index',
              'path': '../routes/<user>/<id>/index.dart',
              'route': '/<id>/<user>'
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
      Directory.current = directory;
      File(path.join(routes.path, 'index.dart')).createSync();
      final userDirectory = Directory(path.join(routes.path, '<user>'))
        ..createSync();
      File(path.join(userDirectory.path, '<name>.dart')).createSync();
      final idDirectory = Directory(path.join(userDirectory.path, '<id>'))
        ..createSync();
      File(path.join(idDirectory.path, 'index.dart')).createSync();
      final configuration = buildRouteConfiguration(directory);
      expect(
        configuration.directories.map((d) => d.toJson()).toList(),
        equals(expected),
      );
    });
  });
}
