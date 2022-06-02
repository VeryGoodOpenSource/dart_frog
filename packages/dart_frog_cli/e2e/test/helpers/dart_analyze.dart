import 'dart:io';

Future<void> dartAnalyze(Directory directory) async {
  final result = await Process.run(
    'dart',
    ['analyze', '.'],
    workingDirectory: directory.path,
    runInShell: true,
  );

  if (result.exitCode != 0) {
    throw Exception('dart analyze . exited with code ${result.exitCode}');
  }

  final output = result.stdout as String;
  if (!output.contains('No issues found!')) {
    throw Exception('dart analyze reported problems:\n$output');
  }
}
