import 'dart:io' as io;
import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final dirname = context.vars['dirname'] as String;
  final filename = context.vars['filename'] as String;
  io.Directory(dirname).createSync();
  io.File('$filename.dart').renameSync('$dirname/$filename.dart');
}
