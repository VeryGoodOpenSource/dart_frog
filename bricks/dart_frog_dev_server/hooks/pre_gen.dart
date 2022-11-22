import 'dart:async';
import 'dart:io' as io;

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason/mason.dart' show HookContext;

import 'src/exit_overrides.dart';
import 'src/report_external_path_dependencies.dart';
import 'src/report_rogue_routes.dart';
import 'src/report_route_conflicts.dart';

typedef RouteConfigurationBuilder = RouteConfiguration Function(
  io.Directory directory,
);

void _defaultExit(int code) => ExitOverrides.current?.exit ?? io.exit;

Future<void> run(HookContext context) async => preGen(context);

Future<void> preGen(
  HookContext context, {
  RouteConfigurationBuilder buildConfiguration = buildRouteConfiguration,
  void Function(int exitCode) exit = _defaultExit,
}) async {
  final RouteConfiguration configuration;
  try {
    configuration = buildConfiguration(io.Directory.current);
  } catch (error) {
    context.logger.err('$error');
    return exit(1);
  }

  reportRouteConflicts(context, configuration);
  reportRogueRoutes(context, configuration);
  await reportExternalPathDependencies(context, io.Directory.current);

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
    'invokeCustomEntrypoint': configuration.invokeCustomEntrypoint,
  };
}
