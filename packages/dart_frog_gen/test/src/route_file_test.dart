// Not needed for test file
// ignore_for_file: prefer_const_constructors

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:test/test.dart';

void main() {
  group('RouteFile', () {
    test('copyWith creates a copy (no updates)', () {
      final original = RouteFile(
        name: 'index',
        route: '/',
        path: '/path',
        params: <String>[],
        wildcard: false,
      );
      final copy = original.copyWith();
      expect(copy.name, equals(original.name));
      expect(copy.route, equals(original.route));
      expect(copy.path, equals(original.path));
      expect(copy.params, equals(original.params));
      expect(copy.wildcard, equals(original.wildcard));
    });

    test('copyWith creates a copy (updates)', () {
      final original = RouteFile(
        name: 'index',
        route: '/',
        path: '/path',
        params: <String>[],
        wildcard: false,
      );
      final copy = original.copyWith(
        name: 'copy',
        route: '/copy',
        path: '/copy',
        params: ['copy'],
        wildcard: true,
      );
      expect(copy.name, equals('copy'));
      expect(copy.route, equals('/copy'));
      expect(copy.path, equals('/copy'));
      expect(copy.params, equals(['copy']));
      expect(copy.wildcard, isTrue);
    });

    test('toJson returns correct map', () {
      final routeFile = RouteFile(
        name: 'index',
        route: '/<id>',
        path: '/path',
        params: <String>['id'],
        wildcard: false,
      );
      expect(
        routeFile.toJson(),
        equals(
          <String, dynamic>{
            'name': 'index',
            'path': '/path',
            'route': '/<id>',
            'file_params': ['id'],
            'wildcard': false,
          },
        ),
      );
    });
  });
}
