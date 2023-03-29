import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../helpers/helpers.dart';

/// Objectives:
///
/// * Generate a new Dart Frog project via `dart_frog create`
/// * Run a dev server via `dart_frog dev -p 8080`
/// * Run another dev server via `dart_frog dev -p 8081`
/// * Ensure the servers responds accordingly for built-in endpoints
void main() {
  group('dart_frog multiple dev', () {
    const projectName = 'example';
    final tempDirectory = Directory.systemTemp.createTempSync();

    late Process process1;
    const port1 = '8080';
    // late Process process2;
    const port2 = '8081';

    setUpAll(() async {
      await dartFrogCreate(projectName: projectName, directory: tempDirectory);
      process1 = await dartFrogDev(
        directory: Directory(path.join(tempDirectory.path, projectName)),
        port: port1,
      );
      /*process2 =*/ await dartFrogDev(
        directory: Directory(path.join(tempDirectory.path, projectName)),
        port: port2,
      );
    });

    tearDownAll(() async {
      await killDartFrogServer(process1.pid, port: port1);
      // FIXME(alestiago): Running killDartFrogServer on MacOs kills both processes.
      // await killDartFrogServer(process2.pid, port: port2);
      tempDirectory.delete(recursive: true).ignore();
    });

    group('server at $port1', () {
      testServer(
        'GET / returns 200 with greeting',
        port: port1,
        (host) async {
          final response = await http.get(Uri.parse(host));
          expect(response.statusCode, equals(HttpStatus.ok));
          expect(response.body, equals('Welcome to Dart Frog!'));
          expect(response.headers, contains('date'));
          expect(
            response.headers,
            containsPair('content-type', 'text/plain; charset=utf-8'),
          );
        },
      );

      testServer(
        'GET /not_here returns 404',
        port: port1,
        (host) async {
          final response = await http.get(Uri.parse('$host/not_here'));
          expect(response.statusCode, HttpStatus.notFound);
          expect(response.body, 'Route not found');
        },
      );
    });

    group('server at $port2', () {
      testServer(
        'GET / returns 200 with greeting',
        port: port2,
        (host) async {
          final response = await http.get(Uri.parse(host));
          expect(response.statusCode, equals(HttpStatus.ok));
          expect(response.body, equals('Welcome to Dart Frog!'));
          expect(response.headers, contains('date'));
          expect(
            response.headers,
            containsPair('content-type', 'text/plain; charset=utf-8'),
          );
        },
      );

      testServer(
        'GET /not_here returns 404',
        port: port2,
        (host) async {
          final response = await http.get(Uri.parse('$host/not_here'));
          expect(response.statusCode, HttpStatus.notFound);
          expect(response.body, 'Route not found');
        },
      );
    });
  });
}
