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

typedef ClientConfigurationBuilder = ClientConfiguration Function(
  io.Directory directory,
);

void _defaultExit(int code) => ExitOverrides.current?.exit ?? io.exit;

Future<void> run(HookContext context) async => preGen(context);

Future<void> preGen(
  HookContext context, {
  RouteConfigurationBuilder getRouteConfiguration = buildRouteConfiguration,
  ClientConfigurationBuilder getClientConfiguration = buildClientConfiguration,
  void Function(int exitCode) exit = _defaultExit,
}) async {
  final RouteConfiguration routeConfiguration;
  try {
    routeConfiguration = getRouteConfiguration(io.Directory.current);
  } catch (error) {
    context.logger.err('$error');
    return exit(1);
  }

  final ClientConfiguration clientConfiguration;
  try {
    clientConfiguration = buildClientConfiguration(io.Directory.current);
  } catch (error) {
    context.logger.err('$error');
    return exit(1);
  }

  reportRouteConflicts(context, routeConfiguration);
  reportRogueRoutes(context, routeConfiguration);
  await reportExternalPathDependencies(context, io.Directory.current);

  context.vars = {
    'port': context.vars['port'] ?? '8080',
    'directories': routeConfiguration.directories
        .map((c) => c.toJson())
        .toList()
        .reversed
        .toList(),
    'routes': routeConfiguration.routes.map((r) => r.toJson()).toList(),
    'middleware': routeConfiguration.middleware.map((m) => m.toJson()).toList(),
    'globalMiddleware': routeConfiguration.globalMiddleware != null
        ? routeConfiguration.globalMiddleware!.toJson()
        : false,
    'serveStaticFiles': routeConfiguration.serveStaticFiles,
    'invokeCustomEntrypoint': routeConfiguration.invokeCustomEntrypoint,
    'invokeCustomInit': routeConfiguration.invokeCustomInit,
    'client': clientConfiguration.toJson(),
  };
}
