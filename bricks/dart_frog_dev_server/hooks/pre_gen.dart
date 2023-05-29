import 'dart:async';
import 'dart:io' as io;

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason/mason.dart'
    show HookContext, defaultForeground, lightCyan;

import 'src/exit_overrides.dart';

typedef RouteConfigurationBuilder = RouteConfiguration Function(
  io.Directory directory,
);

void _defaultExit(int code) => ExitOverrides.current?.exit ?? io.exit;

Future<void> run(HookContext context) async => preGen(context);

Future<void> preGen(
  HookContext context, {
  io.Directory? directory,
  RouteConfigurationBuilder buildConfiguration = buildRouteConfiguration,
  void Function(int exitCode) exit = _defaultExit,
}) async {
  final projectDirectory = directory ?? io.Directory.current;

  final RouteConfiguration configuration;
  try {
    configuration = buildConfiguration(io.Directory.current);
  } catch (error) {
    context.logger.err('$error');
    return exit(1);
  }

  reportRouteConflicts(
    configuration,
    onViolationStart: () {
      context.logger.info('');
    },
    onRouteConflict: (
      originalFilePath,
      conflictingFilePath,
      conflictingEndpoint,
    ) {
      context.logger.err(
        '''Route conflict detected. ${lightCyan.wrap(originalFilePath)} and ${lightCyan.wrap(conflictingFilePath)} both resolve to ${lightCyan.wrap(conflictingEndpoint)}.''',
      );
    },
  );
  reportRogueRoutes(
    configuration,
    onViolationStart: () {
      context.logger.info('');
    },
    onRogueRoute: (filePath, idealPath) {
      context.logger.err(
        '''Rogue route detected.${defaultForeground.wrap(' ')}Rename ${lightCyan.wrap(filePath)} to ${lightCyan.wrap(idealPath)}.''',
      );
    },
  );
  await reportExternalPathDependencies(
    projectDirectory,
    onViolationStart: () {
      context.logger
        ..info('')
        ..err('All path dependencies must be within the project.')
        ..err('External path dependencies detected:');
    },
    onExternalPathDependency: (dependencyName, dependencyPath) {
      context.logger.err('  \u{2022} $dependencyName from $dependencyPath');
    },
  );

  context.vars = {
    'port': context.vars['port'] ?? '8080',
    'directories':
        configuration.orderedDirectories().map((c) => c.toJson()).toList(),
    'routes': configuration.routes.map((r) => r.toJson()).toList(),
    'middleware': configuration.middleware.map((m) => m.toJson()).toList(),
    'globalMiddleware': configuration.globalMiddleware != null
        ? configuration.globalMiddleware!.toJson()
        : false,
    'serveStaticFiles': configuration.serveStaticFiles,
    'invokeCustomEntrypoint': configuration.invokeCustomEntrypoint,
    'invokeCustomInit': configuration.invokeCustomInit,
  };
}
