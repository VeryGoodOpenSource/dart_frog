import 'dart:io';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

Future<void> run(HookContext context) async {
  context.logger.info('');
  final done = context.logger.progress('Installing dependencies');
  await Process.run('dart', ['pub', 'get'], runInShell: true);
  done();

  final projectDirectory = path.canonicalize(
    path.join(Directory.current.path, context.vars['name']),
  );

  context.logger
    ..info('')
    ..success('Created ${context.vars['name']} at $projectDirectory.')
    ..info('')
    ..info('Get started by typing:')
    ..info('')
    ..info('${lightCyan.wrap('cd')} $projectDirectory')
    ..info('${lightCyan.wrap('dart_frog dev')}');
}
