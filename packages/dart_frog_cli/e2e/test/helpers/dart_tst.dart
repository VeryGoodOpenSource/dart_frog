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

  final output = result.stdout as String;
  if (!output.contains('All tests passed!')) {
    throw Exception('dart test reported test failures:\n$output');
  }
}
