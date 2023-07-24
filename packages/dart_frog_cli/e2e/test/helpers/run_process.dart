import 'dart:io';

Future<ProcessResult> runProcess(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
  Map<String, String>? environment,
  bool includeParentEnvironment = true,
  bool runInShell = false,
}) async {
  final result = await Process.run(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    runInShell: runInShell,
  );

  if (result.exitCode != 0) {
    final commandLine = [executable, ...arguments].join(' ');

    throw Exception('''
"$commandLine" exited with code ${result.exitCode}. 
 stderr: ${result.stderr}
 stdout: ${result.stdout}
''');
  }

  return result;
}
