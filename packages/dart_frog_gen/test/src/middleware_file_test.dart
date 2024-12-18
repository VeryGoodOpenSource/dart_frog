// Not needed for test file
// ignore_for_file: prefer_const_constructors

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:test/test.dart';

void main() {
  group('MiddlewareFile', () {
    test('copyWith creates a copy (no updates)', () {
      final original = MiddlewareFile(name: 'index', path: '/path');
      final copy = original.copyWith();
      expect(copy.name, equals(original.name));
      expect(copy.path, equals(original.path));
    });

    test('copyWith creates a copy (updates)', () {
      final original = MiddlewareFile(name: 'index', path: '/path');
      final copy = original.copyWith(
        name: 'copy',
        path: '/copy',
      );
      expect(copy.name, equals('copy'));
      expect(copy.path, equals('/copy'));
    });

    test('toJson returns correct map', () {
      final middlewareFile = MiddlewareFile(name: 'index', path: '/path');
      expect(
        middlewareFile.toJson(),
        equals(
          <String, dynamic>{'name': 'index', 'path': '/path'},
        ),
      );
    });
  });
}
