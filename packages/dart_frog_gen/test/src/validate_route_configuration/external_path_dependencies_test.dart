import 'dart:io';

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('reportExternalPathDependencies', () {
    late bool violationStartCalled;
    late bool violationEndCalled;
    late List<String> externalPathDependencies;

    setUp(() {
      violationStartCalled = false;
      violationEndCalled = false;
      externalPathDependencies = [];
    });

    test('reports nothing when there are no external path dependencies',
        () async {
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

      await expectLater(
        reportExternalPathDependencies(
          directory,
          onViolationStart: () {
            violationStartCalled = true;
          },
          onViolationEnd: () {
            violationEndCalled = true;
          },
          onExternalPathDependency: (_, dependencyPath) {
            externalPathDependencies.add(dependencyPath);
          },
        ),
        completes,
      );

      expect(violationStartCalled, isFalse);
      expect(violationEndCalled, isFalse);
      expect(externalPathDependencies, isEmpty);
    });

    test('reports when there is a single external path dependency', () async {
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

      await expectLater(
        reportExternalPathDependencies(
          directory,
          onViolationStart: () {
            violationStartCalled = true;
          },
          onViolationEnd: () {
            violationEndCalled = true;
          },
          onExternalPathDependency: (_, dependencyPath) {
            externalPathDependencies.add(dependencyPath);
          },
        ),
        completes,
      );

      expect(violationStartCalled, isTrue);
      expect(violationEndCalled, isTrue);
      expect(externalPathDependencies, ['../../foo']);

      directory.delete(recursive: true).ignore();
    });

    test('reports when there are multiple external path dependencies',
        () async {
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
  bar:
    path: ../../bar
''',
      );
      await expectLater(
        reportExternalPathDependencies(
          directory,
          onViolationStart: () {
            violationStartCalled = true;
          },
          onViolationEnd: () {
            violationEndCalled = true;
          },
          onExternalPathDependency: (_, dependencyPath) {
            externalPathDependencies.add(dependencyPath);
          },
        ),
        completes,
      );

      expect(violationStartCalled, isTrue);
      expect(violationEndCalled, isTrue);
      expect(externalPathDependencies, ['../../foo', '../../bar']);

      directory.delete(recursive: true).ignore();
    });
  });
}
