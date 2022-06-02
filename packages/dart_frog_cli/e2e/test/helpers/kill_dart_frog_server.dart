import 'dart:io';

Future<void> killDartFrogServer(int pid) async {
  if (Platform.isWindows) {
    final result = await Process.run(
      'taskkill',
      ['/F', '/T', '/PID', '$pid'],
      runInShell: true,
    );
    if (result.exitCode != 0) {
      throw Exception('taskkill /F /T /PID $pid exited with code $exitCode');
    }
    return;
  }

  if (Platform.isLinux || Platform.isMacOS) {
    final result = await Process.run('pkill', ['-f', 'dart_frog']);
    if (result.exitCode != 0) {
      throw Exception('pkill -f dart_frog exited with code $exitCode');
    }
    return;
  }
}
