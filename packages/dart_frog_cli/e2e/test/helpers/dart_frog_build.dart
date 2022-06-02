import 'dart:io';

Future<void> dartFrogBuild({
  required Directory directory,
}) async {
  final result = await Process.run(
    'dart_frog',
    ['build'],
    workingDirectory: directory.path,
    runInShell: true,
  );
  if (result.exitCode != 0) {
    throw Exception('dart_frog build exited with code ${result.exitCode}');
  }
}
