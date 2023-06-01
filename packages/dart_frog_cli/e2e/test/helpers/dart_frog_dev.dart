import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<Process> dartFrogDev({
  required Directory directory,
  List<String> args = const [],
  bool exitOnError = true,
}) async {
  final completer = Completer<Process>();

  final process = await Process.start(
    'dart_frog',
    ['dev', ...args],
    workingDirectory: directory.path,
    runInShell: true,
  );

  late StreamSubscription<List<int>> stdoutSubscription;
  late StreamSubscription<List<int>> stderrSubscription;

  stdoutSubscription = process.stdout.listen((event) {
    final message = utf8.decode(event);
    if (message.contains('Hot reload is enabled.')) {
      stdoutSubscription.cancel();
      stderrSubscription.cancel();
      completer.complete(process);
    }
  });

  stderrSubscription = process.stderr.listen((event) {
    final message = utf8.decode(event);
    stdoutSubscription.cancel();
    stderrSubscription.cancel();
    completer.completeError(message);
    if (exitOnError) exit(1);
  });

  return completer.future;
}
