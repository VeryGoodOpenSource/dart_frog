import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import 'helpers/helpers.dart';

/// Objectives:
///
/// * Generate a new Dart Frog project via `dart_frog create`
/// * Run the dev server via `dart_frog dev`
/// * Ensure the server responds accordingly for built-in endpoints
void main() {
  group('dart_frog dev', () {
    const projectName = 'example';
    final tempDirectory = Directory.systemTemp.createTempSync();

    late Process process;

    setUpAll(() async {
      await dartFrogCreate(projectName: projectName, directory: tempDirectory);
      process = await dartFrogDev(
        directory: Directory(path.join(tempDirectory.path, projectName)),
      );
    });

    tearDownAll(() async {
      killDartFrogServer(process.pid).ignore();
      tempDirectory.delete(recursive: true).ignore();
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
