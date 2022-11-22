import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../src/get_path_dependencies.dart';

void main() {
  group('getPathDependencies', () {
    test('returns nothing when there are no path dependencies', () {
      final directory = Directory.systemTemp.createTempSync();
      File(path.join(directory.path, 'pubspec.yaml')).writeAsStringSync(
        '''
name: example
version: 0.1.0
environment:
  sdk: ^2.17.0
dependencies:
  mason: any
dev_dependencies:
  test: any
''',
      );
      expect(getPathDependencies(directory), completion(isEmpty));
      directory.delete(recursive: true).ignore();
    });

    test('returns correct path dependencies', () {
      final directory = Directory.systemTemp.createTempSync();
      File(path.join(directory.path, 'pubspec.yaml')).writeAsStringSync(
        '''
name: example
version: 0.1.0
environment:
  sdk: ^2.17.0
dependencies:
  mason: any
  dart_frog:
    path: ./path/to/dart_frog
dev_dependencies:
  test: any
  dart_frog_gen:
    path: ./path/to/dart_frog_gen  
''',
      );
      expect(
        getPathDependencies(directory),
        completion(
          equals(['./path/to/dart_frog', './path/to/dart_frog_gen']),
        ),
      );
      directory.delete(recursive: true).ignore();
    });
  });
}
