// ignore_for_file: public_member_api_docs, only_throw_errors

import 'dart:async';
import 'dart:io' as io;

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason/mason.dart';

Future<Map<String, dynamic>> preGen({
  required Logger logger,
  required String? port,
  required io.Directory projectDirectory,
  RouteConfigurationBuilder buildConfiguration = buildRouteConfiguration,
}) async {
  final RouteConfiguration configuration;
  try {
    configuration = buildConfiguration(projectDirectory);
  } catch (error) {
    logger.err('$error');
    throw 'opsie';
  }

  reportRouteConflicts(
    configuration,
    onViolationStart: () {
      logger.info('');
    },
    onRouteConflict: (
      originalFilePath,
      conflictingFilePath,
      conflictingEndpoint,
    ) {
      logger.err(
        '''Route conflict detected. ${lightCyan.wrap(originalFilePath)} and ${lightCyan.wrap(conflictingFilePath)} both resolve to ${lightCyan.wrap(conflictingEndpoint)}.''',
      );
    },
  );
  reportRogueRoutes(
    configuration,
    onViolationStart: () {
      logger.info('');
    },
    onRogueRoute: (filePath, idealPath) {
      logger.err(
        '''Rogue route detected.${defaultForeground.wrap(' ')}Rename ${lightCyan.wrap(filePath)} to ${lightCyan.wrap(idealPath)}.''',
      );
    },
  );

  return {
    'port': port ?? '8080',
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
  };
}
