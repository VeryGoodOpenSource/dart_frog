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

    throw RunProcessException(
      '"$commandLine" exited with code ${result.exitCode}',
      stderr: result.stderr as String,
      stdout: result.stdout as String,
    );
  }

  return result;
}

class RunProcessException implements Exception {
  RunProcessException(
    this.message, {
    required this.stderr,
    required this.stdout,
  });

  final String message;

  final String stderr;
  final String stdout;

  @override
  String toString() {
    return '''
$message
- stderr: $stderr
- stdout: $stdout
''';
  }
}
