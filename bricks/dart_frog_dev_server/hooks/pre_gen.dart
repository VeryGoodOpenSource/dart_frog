import 'dart:io';

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

typedef RouteConfigurationBuilder = RouteConfiguration Function(
  Directory directory,
);

Future<void> run(
  HookContext context, {
  RouteConfigurationBuilder buildConfiguration = buildRouteConfiguration,
  void Function(int exitCode) exit = exit,
}) async {
  final RouteConfiguration configuration;
  try {
    configuration = buildConfiguration(Directory.current);
  } catch (error) {
    context.logger.err('$error');
    return exit(1);
  }

  reportRouteConflicts(context, configuration);

  context.vars = {
    'port': context.vars['port'] ?? '8080',
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
  };
}

void reportRouteConflicts(
  HookContext context,
  RouteConfiguration configuration,
) {
  final conflictingEndpoints =
      configuration.endpoints.entries.where((entry) => entry.value.length > 1);
  if (conflictingEndpoints.isNotEmpty) {
    context.logger.info('');
    for (final conflict in conflictingEndpoints) {
      final originalFilePath = path.normalize(
        path.join('routes', conflict.value.first.path),
      );
      final conflictingFilePath = path.normalize(
        path.join('routes', conflict.value.last.path),
      );
      context.logger.err(
        '''Route conflict detected. ${lightCyan.wrap(originalFilePath)} and ${lightCyan.wrap(conflictingFilePath)} both resolve to ${lightCyan.wrap(conflict.key)}.''',
      );
    }
    context.logger.info('');
  }
}
