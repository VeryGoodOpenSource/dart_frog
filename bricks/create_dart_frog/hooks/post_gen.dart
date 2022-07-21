import 'dart:io';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

Future<void> run(HookContext context) async {
  final projectDirectory = path.canonicalize(
    context.vars['output_directory'] as String? ?? Directory.current.path,
  );
  final progress = context.logger.progress('Installing dependencies');
  await Process.run(
    'dart',
    ['pub', 'get'],
    runInShell: true,
    workingDirectory: projectDirectory,
  );
  progress.complete();

  context.logger
    ..info('')
    ..success('Created ${context.vars['name']} at $projectDirectory.')
    ..info('')
    ..info('Get started by typing:')
    ..info('')
    ..info('${lightCyan.wrap('cd')} $projectDirectory')
    ..info('${lightCyan.wrap('dart_frog dev')}');
}
