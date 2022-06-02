import 'dart:io';

Future<void> dartFormat(Directory directory) async {
  final result = await Process.run(
    'dart',
    ['format', '--set-exit-if-changed', '.'],
    workingDirectory: directory.path,
    runInShell: true,
  );

  if (result.exitCode != 0) {
    throw Exception(
      'dart format --set-exit-if-changed . exited with code ${result.exitCode}',
    );
  }
}
