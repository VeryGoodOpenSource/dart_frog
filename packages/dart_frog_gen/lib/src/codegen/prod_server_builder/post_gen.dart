// ignore_for_file: only_throw_errors, public_member_api_docs

import 'dart:async';
import 'dart:io' as io;

import 'package:mason/mason.dart' show  Logger, lightCyan;
import 'package:path/path.dart' as path;


// topo(renancaraujo): move this to the cli
typedef ProcessRunner = Future<io.ProcessResult> Function(
  String executable,
  List<String> arguments, {
  String workingDirectory,
  bool runInShell,
});

// topo(renancaraujo): move this to the cli
Future<void> _dartPubGet({
  required Logger logger,
  required String workingDirectory,
  required ProcessRunner runProcess,
}) async {
  final progress = logger.progress('Installing dependencies');
  try {
    final result = await runProcess(
      'dart',
      ['pub', 'get'],
      workingDirectory: workingDirectory,
      runInShell: true,
    );
    progress.complete();

    if (result.exitCode != 0) {
      logger.err('${result.stderr}');
      throw 'oopsie';
    }
  } on io.ProcessException catch (error) {
    logger.err(error.message);
    throw 'oopsie';
  }
}

Future<void> postGen({
  required Logger logger,
  required io.Directory workingDirectory,
  ProcessRunner runProcess = io.Process.run,
}) async {

  final buildDirectoryPath = path.join(workingDirectory.path, 'build');

  await _dartPubGet(
    logger: logger,
    workingDirectory: buildDirectoryPath,
    runProcess: runProcess,
  );

  // TODO(renancaraujo): all of this could be in the CLI
  final relativeBuildPath = path.relative(buildDirectoryPath);
  logger
    ..info('')
    ..success('Created a production build!')
    ..info('')
    ..info('Start the production server by running:')
    ..info('')
    ..info(
      '''${lightCyan.wrap('dart ${path.join(relativeBuildPath, 'bin', 'server.dart')}')}''',
    );
}
