import 'dart:io';

import 'helpers.dart';

Future<void> killDartFrogServer(int pid) async {
  if (Platform.isWindows) {
    await runProcess(
      'taskkill',
      ['/F', '/T', '/PID', '$pid'],
      runInShell: true,
    );

    return;
  }

  if (Platform.isLinux) {
    await runProcess('fuser', ['-n', 'tcp', '-k', '8080']);

    return;
  }

  if (Platform.isMacOS) {
    await runProcess('pkill', ['-f', 'dart_frog']);

    return;
  }
}
