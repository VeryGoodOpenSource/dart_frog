import 'dart:io';

import 'package:mason/mason.dart';
import 'package:dart_frog_gen/dart_frog_gen.dart';

Future<void> run(HookContext context) async {
  final RouteConfiguration configuration;
  try {
    configuration = buildRouteConfiguration(Directory.current);
  } catch (error) {
    context.logger.err('$error');
    exit(1);
  }

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
