import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import 'helpers/helpers.dart';

/// Objectives:
///
/// * Generate a new Dart Frog project via `dart_frog create`
/// * Generate a production build via `dart_frog build`
/// * Ensure the server responds accordingly for built-in endpoints
void main() {
  group('dart_frog build', () {
    const projectName = 'example';
    final tempDirectory = Directory.systemTemp.createTempSync();
    final projectDirectory = Directory(
      path.join(tempDirectory.path, projectName),
    );

    late Isolate isolate;

    setUpAll(() async {
      await dartFrogCreate(projectName: projectName, directory: tempDirectory);
      await dartFrogBuild(directory: projectDirectory);
      isolate = await Isolate.spawnUri(
        Uri.file(
          path.join(projectDirectory.path, 'build', 'bin', 'server.dart'),
        ),
        [],
        null,
      );
    });

    tearDownAll(() async {
      isolate.kill();
      await tempDirectory.delete(recursive: true);
    });

    test('creates the project directory', () {
      final entities = tempDirectory.listSync();
      expect(entities.length, equals(1));
      expect(path.basename(entities.first.path), equals(projectName));
    });

    testServer('GET / returns 200 with greeting', (host) async {
      final response = await http.get(Uri.parse(host));
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals('Welcome to Dart Frog!'));
      expect(response.headers, contains('date'));
      expect(
        response.headers,
        containsPair('content-type', 'text/plain; charset=utf-8'),
      );
    });

    testServer('GET /not_here returns 404', (host) async {
      final response = await http.get(Uri.parse('$host/not_here'));
      expect(response.statusCode, HttpStatus.notFound);
      expect(response.body, 'Route not found');
    });
  });
}
