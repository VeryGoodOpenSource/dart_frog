import 'dart:io';

Future<void> killDartFrogServer(int pid) async {
  if (Platform.isWindows) {
    final result = await Process.run(
      'taskkill',
      ['/F', '/T', '/PID', '$pid'],
      runInShell: true,
    );

    if (result.exitCode != 0) {
      throw Exception(
        'taskkill /F /T /PID $pid exited with code ${result.exitCode}',
      );
    }

    return;
  }

  if (Platform.isLinux) {
    final result = await Process.run('fuser', ['-n', 'tcp', '-k', '8080']);

    if (result.exitCode != 0) {
      throw Exception(
        'fuser -n tcp -k 8080 exited with code ${result.exitCode}',
      );
    }

    return;
  }

  if (Platform.isMacOS) {
    final result = await Process.run('pkill', ['-f', 'dart_frog']);

    if (result.exitCode != 0) {
      throw Exception('pkill -f dart_frog exited with code ${result.exitCode}');
    }

    return;
  }
}
