import 'dart:async';
import 'dart:io' as io;

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:io/io.dart' as io_expanded;
import 'package:mason/mason.dart'
    show HookContext, defaultForeground, lightCyan;
import 'package:path/path.dart' as path;

import 'src/create_bundle.dart';
import 'src/create_external_packages_folder.dart';
import 'src/dart_pub_get.dart';
import 'src/exit_overrides.dart';
import 'src/get_path_dependencies.dart';

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

  await createBundle(context, projectDirectory, exit);

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

  // Get all the internal path packages
  final internalPathDependencies = (await getPathDependencies(projectDirectory))
      .where(
        (dependencyPath) =>
            path.isWithin(projectDirectory.path, dependencyPath),
      )
      .toList();

  // Then create the external packages folder
  // and add it to the list of path packages.
  final externalDependencies = await createExternalPackagesFolder(
    projectDirectory,
    copyPath: copyPath,
  );

  final pathDependencies = [
    ...internalPathDependencies,
    ...externalDependencies,
  ];

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
    'pathDependencies': pathDependencies,
    'dartVersion': context.vars['dartVersion'],
    'addDockerfile': addDockerfile,
  };
}
