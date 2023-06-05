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
      await killDartFrogServer(process.pid);
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

  group('dart_frog dev when ran multiple times', () {
    const projectName1 = 'example1';
    const projectName2 = 'example2';

    final tempDirectory = Directory.systemTemp.createTempSync();

    Process? process1;
    Process? process2;

    setUp(() async {
      await dartFrogCreate(projectName: projectName1, directory: tempDirectory);
      await dartFrogCreate(projectName: projectName2, directory: tempDirectory);
    });

    tearDown(() async {
      if (process1 != null) {
        killDartFrogServer(process1!.pid).ignore();
      }

      if (process2 != null) {
        killDartFrogServer(process2!.pid).ignore();
      }
    });

    tearDownAll(() {
      tempDirectory.delete(recursive: true).ignore();
    });

    test(
      'running two different dart_frog dev command will fail '
      'when different dart vm port is not set',
      () async {
        process1 = await dartFrogDev(
          directory: Directory(path.join(tempDirectory.path, projectName1)),
        );

        try {
          await dartFrogDev(
            directory: Directory(path.join(tempDirectory.path, projectName2)),
            exitOnError: false,
          ).then((process) => process2 = process);

          fail('exception not thrown');
        } catch (e) {
          expect(
            e,
            contains(
              '''Could not start the VM service: localhost:8181 is already in use.''',
            ),
          );
        }
      },
    );

    test(
      'runs two different dart_frog dev servers without any issues',
      () async {
        expect(
          dartFrogDev(
            directory: Directory(path.join(tempDirectory.path, projectName1)),
          ).then((process) => process1 = process),
          completes,
        );

        expect(
          dartFrogDev(
            directory: Directory(path.join(tempDirectory.path, projectName2)),
            exitOnError: false,
            args: ['--dart-vm-service-port', '9191'],
          ).then((process) => process2 = process),
          completes,
        );
      },
    );
  });
}
