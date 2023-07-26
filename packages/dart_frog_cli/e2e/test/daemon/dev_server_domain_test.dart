import 'dart:async';
import 'dart:io';

import 'package:dart_frog_cli/src/daemon/daemon.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../helpers/helpers.dart';

/// Objectives:
///
/// * Generate a new Dart Frog project via `dart_frog create`
/// * Generate a new Dart Frog project via `dart_frog create` in another spot
/// * Start the daemon
/// * start a serve on project1
/// * start a serve on project2
/// * start another server on project 1
/// * verify if servers are running
/// * modify files in project 2
/// * verify if server on project 2 is reloaded
/// * stop a server on project 1
/// * stop the deamon
/// * verify if servers stopped
void main() {
  const projectName1 = 'example1';
  const projectName2 = 'example2';
  final tempDirectory = Directory.systemTemp.createTempSync();
  final projectDirectory1 = Directory(
    path.join(tempDirectory.path, projectName1),
  );
  final projectDirectory2 = Directory(
    path.join(tempDirectory.path, projectName2),
  );

  late Process daemonProcess;

  late final DaemonStdioHelper daemonStdio;

  var requestCount = 0;

  setUpAll(() async {
    await dartFrogCreate(
      projectName: projectName1,
      directory: tempDirectory,
    );
    await dartFrogCreate(
      projectName: projectName2,
      directory: tempDirectory,
    );

    daemonProcess = await dartFrogDaemonStart();
    daemonStdio = DaemonStdioHelper(daemonProcess);
    addTearDown(() async {
      daemonProcess.kill(ProcessSignal.sigkill);
      daemonStdio.dispose();
    });

    await daemonStdio.awaitForDaemonEvent('daemon.ready');
  });

  group('dev server domain', () {
    late String project1Server1Id;
    late String project1Server2Id;
    late String project2ServerId;

    test('start first dev server on project 1', () async {
      final response = await daemonStdio.sendDaemonRequest(
        DaemonRequest(
          id: '${++requestCount}',
          domain: 'dev_server',
          method: 'start',
          params: {
            'workingDirectory': projectDirectory1.path,
            'port': 8080,
            'dartVmServicePort': 8081
          },
        ),
      );

      expect(response.isSuccess, isTrue);
      project1Server1Id = response.result!['applicationId'] as String;

      try {
        final earlyExitEvent = await daemonStdio.awaitForDaemonEvent(
          'dev_server.applicationExit',
          withParamsThat: containsPair('applicationId', project1Server1Id),
          timeout: const Duration(seconds: 5),
        );

        fail('Server exited too early: $earlyExitEvent');
      } on TimeoutException {
        // Expected
      }
    });

    test('start dev server on project 2', () async {
      final response = await daemonStdio.sendDaemonRequest(
        DaemonRequest(
          id: '${++requestCount}',
          domain: 'dev_server',
          method: 'start',
          params: {
            'workingDirectory': projectDirectory2.path,
            'port': 8090,
            'dartVmServicePort': 8091
          },
        ),
      );

      expect(response.isSuccess, isTrue);
      project2ServerId = response.result!['applicationId'] as String;

      try {
        final earlyExitEvent = await daemonStdio.awaitForDaemonEvent(
          'dev_server.applicationExit',
          withParamsThat: containsPair('applicationId', project2ServerId),
          timeout: const Duration(seconds: 5),
        );

        fail('Server exited too early: $earlyExitEvent');
      } on TimeoutException {
        // Expected
      }
    });

    test('start second dev server on project 1', () async {
      final response = await daemonStdio.sendDaemonRequest(
        DaemonRequest(
          id: '${++requestCount}',
          domain: 'dev_server',
          method: 'start',
          params: {
            'workingDirectory': projectDirectory1.path,
            'port': 9090,
            'dartVmServicePort': 9091
          },
        ),
      );

      expect(response.isSuccess, isTrue);
      project1Server2Id = response.result!['applicationId'] as String;

      try {
        final earlyExitEvent = await daemonStdio.awaitForDaemonEvent(
          'dev_server.applicationExit',
          withParamsThat: containsPair('applicationId', project1Server2Id),
          timeout: const Duration(seconds: 5),
        );

        fail('Server exited too early: $earlyExitEvent');
      } on TimeoutException {
        // Expected
      }
    });

    testServer('GET / on project 1 server 1', (host) async {
      final response = await http.get(Uri.parse(host));
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals('Welcome to Dart Frog!'));
      expect(response.headers, contains('date'));
      expect(
        response.headers,
        containsPair('content-type', 'text/plain; charset=utf-8'),
      );
    });

    testServer(port: 8090, 'GET / on project 2', (host) async {
      final response = await http.get(Uri.parse(host));
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals('Welcome to Dart Frog!'));
      expect(response.headers, contains('date'));
      expect(
        response.headers,
        containsPair('content-type', 'text/plain; charset=utf-8'),
      );
    });

    testServer(port: 9090, 'GET / on project 1 server 2', (host) async {
      final response = await http.get(Uri.parse(host));
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals('Welcome to Dart Frog!'));
      expect(response.headers, contains('date'));
      expect(
        response.headers,
        containsPair('content-type', 'text/plain; charset=utf-8'),
      );
    });

    test('modify files on project 2', () async {
      final routesDirectory = Directory(
        path.join(
          projectDirectory2.path,
          'routes',
        ),
      );

      expect(fileAt('index.dart', on: routesDirectory), exists);

      await dartFrogNewRoute('new_route', directory: projectDirectory2);

      expect(fileAt('new_route.dart', on: routesDirectory), exists);
    });

    test('reload project 2', () async {
      final response = await daemonStdio.sendDaemonRequest(
        DaemonRequest(
          id: '${++requestCount}',
          domain: 'dev_server',
          method: 'reload',
          params: {
            'applicationId': project2ServerId,
          },
        ),
      );

      expect(response.isSuccess, isTrue);
    });

    testServer(port: 8090, 'GET /new_route on project 2', (host) async {
      final response = await http.get(Uri.parse(host));
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.headers, contains('date'));
      expect(
        response.headers,
        containsPair('content-type', 'text/plain; charset=utf-8'),
      );
    });

    test('stop a dev server on project 1', () async {
      final response = await daemonStdio.sendDaemonRequest(
        DaemonRequest(
          id: '${++requestCount}',
          domain: 'dev_server',
          method: 'stop',
          params: {
            'applicationId': project1Server1Id,
          },
        ),
      );

      if (Platform.isLinux) {
        killDartFrogServer(daemonProcess.pid, port: 8080).ignore();
      }

      expect(response.isSuccess, isTrue);
      expect(response.result!['exitCode'], equals(0));
    });

    test('try to stop same dev server again and expect an error', () async {
      final response = await daemonStdio.sendDaemonRequest(
        DaemonRequest(
          id: '${++requestCount}',
          domain: 'dev_server',
          method: 'stop',
          params: {
            'applicationId': project1Server1Id,
          },
        ),
      );

      expect(response.isSuccess, isFalse);
      expect(response.error!['message'], 'Application not found');
    });

    test('kill the daemon', () async {
      final response = await daemonStdio.sendDaemonRequest(
        const DaemonRequest(id: '1', domain: 'daemon', method: 'kill'),
      );

      expect(
        response.result,
        equals({'message': 'Hogarth. You stay, I go. No following.'}),
      );

      if (Platform.isLinux) {
        killDartFrogServer(daemonProcess.pid, port: 8090).ignore();
        killDartFrogServer(daemonProcess.pid, port: 9090).ignore();
      }

      await Future<void>.delayed(const Duration(seconds: 10));
      final exitCode = await daemonProcess.exitCode;

      expect(exitCode, equals(0));
    });

    testServer('GET on project 1 server 1: connection refused', (host) async {
      final responseFuture = http.get(Uri.parse(host));

      await expectLater(
        responseFuture,
        throwsA(isA<SocketException>()),
      );
    });

    testServer(
      port: 8090,
      'GET / on project 2: connection refused',
      (host) async {
        final responseFuture = http.get(Uri.parse(host));

        await expectLater(
          responseFuture,
          throwsA(
            isA<SocketException>(),
          ),
        );
      },
    );

    testServer(
      port: 9090,
      'GET / on project 1 server 2: connection refused',
      (host) async {
        await expectLater(
          () async {
            final response = await http.get(Uri.parse(host));
            stderr
              ..writeln(response.statusCode)
              ..writeln(response.body);
            return response;
          },
          throwsA(isA<SocketException>()),
        );
      },
    );
  });
}
