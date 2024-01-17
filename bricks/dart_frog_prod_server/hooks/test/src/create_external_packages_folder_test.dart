import 'dart:io';

import 'package:dart_frog_prod_server_hooks/dart_frog_prod_server_hooks.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../pubspec_locks.dart';

void main() {
  group('createExternalPackagesFolder', () {
    test(
      'bundles external dependencies with external dependencies',
      () async {
        final projectDirectory = Directory.systemTemp.createTempSync();
        File(path.join(projectDirectory.path, 'pubspec.yaml'))
            .writeAsStringSync(
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
        File(path.join(projectDirectory.path, 'pubspec.lock'))
            .writeAsStringSync(
          fooPath,
        );
        final copyCalls = <String>[];

        await createExternalPackagesFolder(
          projectDirectory: projectDirectory,
          buildDirectory: Directory(path.join(projectDirectory.path, 'build')),
          copyPath: (from, to) {
            copyCalls.add('$from -> $to');
            return Future.value();
          },
        );

        final from = path.join(projectDirectory.path, '../../foo');
        final to = path.join(
          projectDirectory.path,
          'build',
          '.dart_frog_path_dependencies',
          'foo',
        );
        expect(copyCalls, ['$from -> $to']);
      },
    );

    test(
      "don't bundle internal path dependencies",
      () async {
        final projectDirectory = Directory.systemTemp.createTempSync();
        File(path.join(projectDirectory.path, 'pubspec.yaml'))
            .writeAsStringSync(
          '''
name: example
version: 0.1.0
environment:
  sdk: ^2.17.0
dependencies:
  mason: any
  foo:
    path: ../../foo
  bar:
    path: packages/bar
dev_dependencies:
  test: any
''',
        );
        File(path.join(projectDirectory.path, 'pubspec.lock'))
            .writeAsStringSync(
          fooPathWithInternalDependency,
        );
        final copyCalls = <String>[];

        File(
          path.join(
            projectDirectory.path,
            'packages',
            'bar',
            'pubspec.yaml',
          ),
        )
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '''

name: bar
version: 0.1.0
environment:
  sdk: ^2.17.0
            ''',
          );

        await createExternalPackagesFolder(
          projectDirectory: projectDirectory,
          buildDirectory: Directory(path.join(projectDirectory.path, 'build')),
          copyPath: (from, to) {
            copyCalls.add('$from -> $to');
            return Future.value();
          },
        );

        final from = path.join(projectDirectory.path, '../../foo');
        final to = path.join(
          projectDirectory.path,
          'build',
          '.dart_frog_path_dependencies',
          'foo',
        );
        expect(copyCalls, ['$from -> $to']);
      },
    );
  });
}
