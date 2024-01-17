import 'dart:async';
import 'dart:io' as io;

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:dart_frog_prod_server_hooks/dart_frog_prod_server_hooks.dart';
import 'package:io/io.dart' as io_expanded;
import 'package:mason/mason.dart'
    show HookContext, defaultForeground, lightCyan;
import 'package:path/path.dart' as path;

typedef RouteConfigurationBuilder = RouteConfiguration Function(
  io.Directory directory,
);

void _defaultExit(int code) => ExitOverrides.current?.exit ?? io.exit;

Future<void> run(HookContext context) => preGen(context);

Future<void> preGen(
  HookContext context, {
  io.Directory? directory,
  ProcessRunner runProcess = io.Process.run,
  RouteConfigurationBuilder buildConfiguration = buildRouteConfiguration,
  void Function(int exitCode) exit = _defaultExit,
  Future<void> Function(String from, String to) copyPath = io_expanded.copyPath,
}) async {
  final projectDirectory = directory ?? io.Directory.current;

  // We need to make sure that the pubspec.lock file is up to date
  await dartPubGet(
    context,
    workingDirectory: projectDirectory.path,
    runProcess: runProcess,
    exit: exit,
  );

  final buildDirectory = io.Directory(
    path.join(projectDirectory.path, 'build'),
  );

  await createBundle(
    context: context,
    projectDirectory: projectDirectory,
    buildDirectory: buildDirectory,
    exit: exit,
  );

  final RouteConfiguration configuration;
  try {
    configuration = buildConfiguration(projectDirectory);
  } catch (error) {
    context.logger.err('$error');
    return exit(1);
  }

  reportRouteConflicts(
    configuration,
    onRouteConflict: (
      originalFilePath,
      conflictingFilePath,
      conflictingEndpoint,
    ) {
      context.logger.err(
        '''Route conflict detected. ${lightCyan.wrap(originalFilePath)} and ${lightCyan.wrap(conflictingFilePath)} both resolve to ${lightCyan.wrap(conflictingEndpoint)}.''',
      );
    },
    onViolationEnd: () {
      exit(1);
    },
  );

  reportRogueRoutes(
    configuration,
    onRogueRoute: (filePath, idealPath) {
      context.logger.err(
        '''Rogue route detected.${defaultForeground.wrap(' ')}Rename ${lightCyan.wrap(filePath)} to ${lightCyan.wrap(idealPath)}.''',
      );
    },
    onViolationEnd: () {
      exit(1);
    },
  );

  final customDockerFile = io.File(
    path.join(projectDirectory.path, 'Dockerfile'),
  );

  final internalPathDependencies = await getInternalPathDependencies(
    projectDirectory,
  );

  final externalDependencies = await createExternalPackagesFolder(
    projectDirectory: projectDirectory,
    buildDirectory: buildDirectory,
    copyPath: copyPath,
  );

  final addDockerfile = !customDockerFile.existsSync();

  context.vars = {
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
    'dartVersion': context.vars['dartVersion'],
    'addDockerfile': addDockerfile,
  };
}
