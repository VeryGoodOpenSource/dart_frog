import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> dartFrogDev({required Directory directory}) async {
  final completer = Completer<void>();

  final process = await Process.start(
    'dart_frog',
    ['dev'],
    workingDirectory: directory.path,
  );

  late StreamSubscription stdoutSubscription;
  late StreamSubscription stderrSubscription;
  stdoutSubscription = process.stdout.listen((event) {
    final message = utf8.decode(event);
    if (message.contains('Hot reload is enabled.')) {
      stdoutSubscription.cancel();
      stderrSubscription.cancel();
      completer.complete();
    }
  });
  stderrSubscription = process.stderr.listen((event) {
    final message = utf8.decode(event);
    stdoutSubscription.cancel();
    stderrSubscription.cancel();
    completer.completeError(message);
    exit(1);
  });
  await completer.future;
}
