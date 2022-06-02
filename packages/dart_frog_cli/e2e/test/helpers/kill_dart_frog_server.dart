import 'dart:io';

Future<void> killDartFrogServer() async {
  final result = await Process.run('pkill', ['-f', 'dart_frog']);
  if (result.exitCode != 0) {
    throw Exception('pkill -f dart_frog exited with code $exitCode');
  }
}
