import 'dart:io';

import 'run_process.dart';

Future<void> dartFrogCreate({
  required String projectName,
  required Directory directory,
}) async {
  await runProcess(
    'dart_frog',
    ['create', projectName],
    workingDirectory: directory.path,
    runInShell: true,
  );
}
