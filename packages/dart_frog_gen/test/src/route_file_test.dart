// ignore_for_file: prefer_const_constructors

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:test/test.dart';

void main() {
  group('RouteFile', () {
    test('copyWith creates a copy (no updates)', () {
      final original = RouteFile(name: 'index', route: '/', path: '/path');
      final copy = original.copyWith();
      expect(copy.name, equals(original.name));
      expect(copy.route, equals(original.route));
      expect(copy.path, equals(original.path));
    });

    test('copyWith creates a copy (updates)', () {
      final original = RouteFile(name: 'index', route: '/', path: '/path');
      final copy = original.copyWith(
        name: 'copy',
        route: '/copy',
        path: '/copy',
      );
      expect(copy.name, equals('copy'));
      expect(copy.route, equals('/copy'));
      expect(copy.path, equals('/copy'));
    });

    test('toJson returns correct map', () {
      final routeFile = RouteFile(name: 'index', route: '/', path: '/path');
      expect(
        routeFile.toJson(),
        equals(
          <String, dynamic>{'name': 'index', 'path': '/path', 'route': '/'},
        ),
      );
    });
  });
}
