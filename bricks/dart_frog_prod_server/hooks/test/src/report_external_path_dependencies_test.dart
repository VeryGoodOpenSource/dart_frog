import 'dart:io';

import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../src/report_external_path_dependencies.dart';

class _MockHookContext extends Mock implements HookContext {}

class _MockLogger extends Mock implements Logger {}

void main() {
  group('reportExternalPathDependencies', () {
    late HookContext context;
    late Logger logger;

    setUp(() {
      context = _MockHookContext();
      logger = _MockLogger();

      when(() => context.logger).thenReturn(logger);
    });

    test('reports nothing when there are no external path dependencies',
        () async {
      final exitCalls = <int>[];
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
        reportExternalPathDependencies(context, directory, exitCalls.add),
        completes,
      );
      verifyNever(() => logger.err(any()));
      expect(exitCalls, isEmpty);
      directory.delete(recursive: true).ignore();
    });

    test('reports when there is a single external path dependency', () async {
      final exitCalls = <int>[];
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
        reportExternalPathDependencies(context, directory, exitCalls.add),
        completes,
      );
      expect(exitCalls, equals([1]));
      verify(
        () => logger.err('All path dependencies must be within the project.'),
      ).called(1);
      verify(
        () => logger.err('External path dependencies detected:'),
      ).called(1);
      verify(
        () => logger.err('  \u{2022} foo from ../../foo'),
      ).called(1);
      directory.delete(recursive: true).ignore();
    });

    test('reports when there are multiple external path dependencies',
        () async {
      final exitCalls = <int>[];
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
        reportExternalPathDependencies(context, directory, exitCalls.add),
        completes,
      );
      expect(exitCalls, equals([1]));
      verify(
        () => logger.err('All path dependencies must be within the project.'),
      ).called(1);
      verify(
        () => logger.err('External path dependencies detected:'),
      ).called(1);
      verify(
        () => logger.err('  \u{2022} foo from ../../foo'),
      ).called(1);
      verify(
        () => logger.err('  \u{2022} bar from ../../bar'),
      ).called(1);
      directory.delete(recursive: true).ignore();
    });
  });
}
