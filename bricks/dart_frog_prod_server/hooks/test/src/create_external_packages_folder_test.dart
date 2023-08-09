import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../src/create_external_packages_folder.dart';
import '../pubspeck_locks.dart';

void main() {
  group('createExternalPackagesFolder', () {
    test(
      'bundles external dependencies with external dependencies',
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
''',
        );
        File(path.join(directory.path, 'pubspec.lock')).writeAsStringSync(
          fooPath,
        );
        final copyCalls = <String>[];

        await createExternalPackagesFolder(
          directory,
          copyPath: (from, to) {
            copyCalls.add('$from -> $to');
            return Future.value();
          },
        );

        final from = path.join(directory.path, '../../foo');
        final to = path.join(
          directory.path,
          'build',
          '.dart_frog_path_dependencies',
          'foo',
        );
        expect(copyCalls, ['$from -> $to']);
      },
    );

    // TODO(erickzanardo): test to check that internal dependencies are not bundled
  });
}
