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
      );
      final copy = original.copyWith();
      expect(copy.name, equals(original.name));
      expect(copy.route, equals(original.route));
      expect(copy.middleware, original.middleware);
      expect(copy.files, original.files);
    });

    test('copyWith creates a copy (updates)', () {
      final original = RouteDirectory(
        name: 'index',
        route: '/',
        middleware: null,
        files: [],
      );
      final copy = original.copyWith(
        name: 'copy',
        route: '/copy',
        middleware: MiddlewareFile(name: '/', path: '/'),
        files: [],
      );
      expect(copy.name, equals('copy'));
      expect(copy.route, equals('/copy'));
      expect(copy.middleware, isNotNull);
      expect(copy.files, isEmpty);
    });

    test('toJson returns correct map', () {
      final routeDirectory = RouteDirectory(
        name: 'index',
        route: '/',
        middleware: null,
        files: [RouteFile(name: 'name', path: '/path', route: '/route')],
      );
      expect(
        routeDirectory.toJson(),
        equals(<String, dynamic>{
          'name': 'index',
          'route': '/',
          'middleware': false,
          'files': [
            <String, dynamic>{
              'name': 'name',
              'path': '/path',
              'route': '/route'
            }
          ]
        }),
      );
    });
  });
}
