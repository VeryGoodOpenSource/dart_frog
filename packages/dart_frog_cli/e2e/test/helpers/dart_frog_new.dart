import 'dart:io';

import 'package:test/test.dart';

import 'run_process.dart';

Future<void> dartFrogNewRoute(
  String routePath, {
  required Directory directory,
}) =>
    _dartFrogNew(
      routePath: routePath,
      what: 'route',
      directory: directory,
    );

Future<void> dartFrogNewMiddleware(
  String routePath, {
  required Directory directory,
}) =>
    _dartFrogNew(
      routePath: routePath,
      what: 'middleware',
      directory: directory,
    );

Future<void> _dartFrogNew({
  required String routePath,
  required String what,
  required Directory directory,
}) async {
  await runProcess(
    'dart_frog',
    ['new', what, routePath],
    workingDirectory: directory.path,
    runInShell: true,
  );
}

Matcher failsWithA({required String message}) {
  return throwsA(
    isA<RunProcessException>().having(
      (e) => e.message.trim(),
      'message',
      message,
    ),
  );
}
