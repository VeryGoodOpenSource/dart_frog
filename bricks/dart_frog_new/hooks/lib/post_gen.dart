import 'dart:io' as io;

import 'package:dart_frog_new_hooks/src/exit_overrides.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

void _defaultExit(int code) => ExitOverrides.current?.exit ?? io.exit;

Future<void> postGen(
  HookContext context, {
  io.Directory? directory,
  void Function(int exitCode) exit = _defaultExit,
}) async {
  final succeeded = context.vars.containsKey('dir_path');
  if (!succeeded) {
    return exit(1);
  }

  final dirPath = context.vars['dir_path'] as String;
  final currentDirectory = directory ?? io.Directory.current;

  final containingDirectoryPath = path.relative(
    io.Directory(path.join(currentDirectory.path, dirPath)).path,
  );
  final filename = context.vars['filename'] as String;
  try {
    io.Directory(containingDirectoryPath).createSync(recursive: true);
    io.File(
      path.join(currentDirectory.path, filename),
    ).renameSync('$containingDirectoryPath/$filename');
  } on Exception catch (error) {
    context.logger.err('$error');
    return exit(1);
  }
}
