import 'dart:async';
import 'dart:io' as io;

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason/mason.dart' show HookContext;

import 'src/create_bundle.dart';
import 'src/exit_overrides.dart';
import 'src/get_path_dependencies.dart';
import 'src/report_external_path_dependencies.dart';
import 'src/report_rogue_routes.dart';
import 'src/report_route_conflicts.dart';

typedef RouteConfigurationBuilder = RouteConfiguration Function(
  io.Directory directory,
);

void _defaultExit(int code) => ExitOverrides.current?.exit ?? io.exit;

Future<void> run(HookContext context) => preGen(context);

Future<void> preGen(
  HookContext context, {
  io.Directory? directory,
  RouteConfigurationBuilder buildConfiguration = buildRouteConfiguration,
  void Function(int exitCode) exit = _defaultExit,
}) async {
  final projectDirectory = directory ?? io.Directory.current;

  await createBundle(context, projectDirectory, exit);

  final RouteConfiguration configuration;
  try {
    configuration = buildConfiguration(projectDirectory);
  } catch (error) {
    context.logger.err('$error');
    return exit(1);
  }

  reportRouteConflicts(context, configuration, exit);
  reportRogueRoutes(context, configuration, exit);
  await reportExternalPathDependencies(context, projectDirectory, exit);

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
    'pathDependencies': await getPathDependencies(projectDirectory),
  };
}
