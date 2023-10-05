// ignore_for_file: only_throw_errors, public_member_api_docs

import 'dart:async';
import 'dart:io' as io;

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:dart_frog_gen/src/codegen/prod_server_builder/create_bundle.dart';
import 'package:dart_frog_gen/src/codegen/prod_server_builder/create_external_packages_folder.dart';
import 'package:dart_frog_gen/src/codegen/prod_server_builder/get_internal_path_dependencies.dart';
import 'package:io/io.dart' as io_expanded;
import 'package:mason/mason.dart' show Logger, defaultForeground, lightCyan;
import 'package:path/path.dart' as path;

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

Future<Map<String, dynamic>> preGen({
  required Logger logger,
  required String? dartVersion,
  required io.Directory projectDirectory,
  ProcessRunner runProcess = io.Process.run,
  RouteConfigurationBuilder buildConfiguration = buildRouteConfiguration,
  Future<void> Function(String from, String to) copyPath = io_expanded.copyPath,
}) async {
  // We need to make sure that the pubspec.lock file is up to date
  await _dartPubGet(
    logger: logger,
    workingDirectory: projectDirectory.path,
    runProcess: runProcess,
  );

  await createBundle(logger, projectDirectory);

  final RouteConfiguration configuration;
  try {
    configuration = buildConfiguration(projectDirectory);
  } catch (error) {
    logger.err('$error');
    throw 'oopsie';
  }

  reportRouteConflicts(
    configuration,
    onRouteConflict: (
      originalFilePath,
      conflictingFilePath,
      conflictingEndpoint,
    ) {
      logger.err(
        '''Route conflict detected. ${lightCyan.wrap(originalFilePath)} and ${lightCyan.wrap(conflictingFilePath)} both resolve to ${lightCyan.wrap(conflictingEndpoint)}.''',
      );
    },
    onViolationEnd: () {
      throw 'oopsie doopsie';
    },
  );

  reportRogueRoutes(
    configuration,
    onRogueRoute: (filePath, idealPath) {
      logger.err(
        '''Rogue route detected.${defaultForeground.wrap(' ')}Rename ${lightCyan.wrap(filePath)} to ${lightCyan.wrap(idealPath)}.''',
      );
    },
    onViolationEnd: () {
      throw 'oopsie doopsie';
    },
  );

  final customDockerFile = io.File(
    path.join(projectDirectory.path, 'Dockerfile'),
  );

  final internalPathDependencies = await getInternalPathDependencies(
    projectDirectory,
  );

  final externalDependencies = await createExternalPackagesFolder(
    projectDirectory,
    copyPath: copyPath,
  );

  final addDockerfile = !customDockerFile.existsSync();

  return {
    'directories': configuration.directories
        .map((c) => c.toJson())
        .toList()
        .reversed
        .toList(),
    'routes': configuration.routes.map((r) => r.toJson()).toList(),
    'middleware': configuration.middleware.map((m) => m.toJson()).toList(),
    'globalMiddleware': configuration.globalMiddleware != null
        ? configuration.globalMiddleware!.toJson()
        : false,
    'serveStaticFiles': configuration.serveStaticFiles,
    'invokeCustomEntrypoint': configuration.invokeCustomEntrypoint,
    'invokeCustomInit': configuration.invokeCustomInit,
    'pathDependencies': internalPathDependencies,
    'hasExternalDependencies': externalDependencies.isNotEmpty,
    'externalPathDependencies': externalDependencies,
    'dartVersion': dartVersion,
    'addDockerfile': addDockerfile,
  };
}
