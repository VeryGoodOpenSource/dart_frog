import 'dart:io';

import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  await Process.run('dart', ['format', '.'], runInShell: true);
}
