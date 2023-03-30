import 'dart:io';

Future<void> killDartFrogServer(int pid, {String port = '8080'}) async {
  if (Platform.isWindows) {
    final result = await Process.run(
      'taskkill',
      ['/F', '/T', '/PID', '$pid'],
      runInShell: true,
    );

    if (result.exitCode != 0) {
      throw Exception(
        '`taskkill /F /T /PID $pid` exited with code ${result.exitCode}',
      );
    }

    return;
  }

  if (Platform.isLinux) {
    final result = await Process.run('fuser', ['-n', 'tcp', '-k', port]);

    if (result.exitCode != 0) {
      throw Exception(
        '`fuser -n tcp -k $port` exited with code ${result.exitCode}',
      );
    }

    return;
  }

  if (Platform.isMacOS) {
    final result = await Process.run('sudo', ['kill', '-9', '$pid']);

    if (result.exitCode != 0) {
      throw Exception(
        '`sudo kill -9 $pid` exited with code ${result.exitCode}',
      );
    }

    return;
  }
}
