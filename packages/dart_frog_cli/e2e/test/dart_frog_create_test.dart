import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import 'helpers/helpers.dart';

/// Objectives:
///
/// * Generate a new Dart Frog project via `dart_frog create`
/// * Ensure the code is formatted (`dart format .`)
/// * Ensure the code has no warnings/errors (`dart analyze .`)
/// * Ensure the tests pass (`dart test`)
void main() {
  group('dart_frog create', () {
    const projectName = 'example';
    final tempDirectory = Directory.systemTemp.createTempSync();
    final projectDirectory = Directory(
      path.join(tempDirectory.path, projectName),
    );

    setUpAll(() async {
      await dartFrogCreate(projectName: projectName, directory: tempDirectory);
    });

    tearDownAll(() async {
      await tempDirectory.delete(recursive: true);
    });

    test('generates a well-formatted project', () {
      expect(dartFormat(projectDirectory), completes);
    });

    test('generates a project that has no analysis errors/warnings', () {
      expect(dartAnalyze(projectDirectory), completes);
    });

    test('generates a project in which all tests pass', () {
      expect(dartTest(projectDirectory), completes);
    });
  });
}
