import 'dart:io';

import 'run_process.dart';

Future<void> dartFormat(Directory directory) async {
  await runProcess(
    'dart',
    ['format', '--set-exit-if-changed', '.'],
    workingDirectory: directory.path,
    runInShell: true,
  );
}
