import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

Future<void> run(HookContext context) async {
  final done = context.logger.progress('Installing dependencies');
  final buildDirectoryPath = path.join(Directory.current.path, 'build');
  final result = await Process.run(
    'dart',
    ['pub', 'get'],
    workingDirectory: buildDirectoryPath,
    runInShell: true,
  );
  done();

  if (result.exitCode != 0) {
    context.logger.err('${result.stderr}');
    exit(result.exitCode);
  }
}
