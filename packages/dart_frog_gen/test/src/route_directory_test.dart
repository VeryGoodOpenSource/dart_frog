// ignore_for_file: prefer_const_constructors

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:test/test.dart';

void main() {
  group('RouteDirectory', () {
    test('copyWith creates a copy (no updates)', () {
      final original = RouteDirectory(
        name: 'index',
        route: '/',
        middleware: null,
        files: [],
        params: [],
      );
      final copy = original.copyWith();
      expect(copy.name, equals(original.name));
      expect(copy.route, equals(original.route));
      expect(copy.middleware, original.middleware);
      expect(copy.files, original.files);
      expect(copy.params, original.params);
    });

    test('copyWith creates a copy (updates)', () {
      final original = RouteDirectory(
        name: 'index',
        route: '/',
        middleware: null,
        files: [],
        params: [],
      );
      final copy = original.copyWith(
        name: 'copy',
        route: '/copy',
        middleware: MiddlewareFile(name: '/', path: '/'),
        files: [],
        params: ['copy'],
      );
      expect(copy.name, equals('copy'));
      expect(copy.route, equals('/copy'));
      expect(copy.middleware, isNotNull);
      expect(copy.files, isEmpty);
      expect(copy.params, equals(['copy']));
    });

    test('toJson returns correct map', () {
      final routeDirectory = RouteDirectory(
        name: 'index',
        route: '/api/v1/users/<id>',
        middleware: null,
        files: [
          RouteFile(
            name: 'name',
            path: '/path',
            route: '/route/<name>',
            params: ['name'],
          )
        ],
        params: ['id'],
      );
      expect(
        routeDirectory.toJson(),
        equals(<String, dynamic>{
          'name': 'index',
          'route': '/api/v1/users/<id>',
          'middleware': false,
          'files': [
            <String, dynamic>{
              'name': 'name',
              'path': '/path',
              'route': '/route/<name>',
              'params': ['name'],
            }
          ],
          'params': <String>['id'],
        }),
      );
    });
  });
}
