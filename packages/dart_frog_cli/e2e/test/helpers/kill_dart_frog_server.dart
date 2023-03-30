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
    final result = await Process.run('kill', ['-9', '$pid']);
    // kill -9 $(lsof -ti:7100)

    if (result.exitCode != 0) {
      throw Exception(
        '`kill -9 $pid` exited with code ${result.exitCode}',
      );
    }

    return;
  }
}
