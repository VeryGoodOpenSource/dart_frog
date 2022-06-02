import 'dart:io';

Future<void> dartTest(Directory directory) async {
  final result = await Process.run(
    'dart',
    ['test'],
    workingDirectory: directory.path,
    runInShell: true,
  );

  if (result.exitCode != 0) {
    throw Exception('dart test exited with code ${result.exitCode}');
  }

  final errors = result.stderr as String;
  if (errors.isNotEmpty) {
    throw Exception('dart test reported errors:\n$errors');
  }
}
