import 'dart:io';

Future<void> dartFrogCreate({
  required String projectName,
  required Directory directory,
}) async {
  final result = await Process.run(
    'dart_frog',
    ['create', projectName],
    workingDirectory: directory.path,
    runInShell: true,
  );

  if (result.exitCode != 0) {
    throw Exception('dart_frog create exited with code ${result.exitCode}');
  }
}
