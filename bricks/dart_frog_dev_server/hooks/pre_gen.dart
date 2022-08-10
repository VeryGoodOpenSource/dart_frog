import 'dart:async';
import 'dart:io' as io;

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

typedef RouteConfigurationBuilder = RouteConfiguration Function(
  io.Directory directory,
);

Future<void> run(HookContext context) async => preGen(context);

Future<void> preGen(
  HookContext context, {
  RouteConfigurationBuilder buildConfiguration = buildRouteConfiguration,
  void Function(int exitCode)? exit,
}) async {
  final RouteConfiguration configuration;
  try {
    configuration = buildConfiguration(io.Directory.current);
  } catch (error) {
    context.logger.err('$error');
    final _exit = exit ?? ExitOverrides.current?.exit ?? io.exit;
    return _exit(1);
  }

  reportRouteConflicts(context, configuration);
  reportRogueRoutes(context, configuration);

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
  }
}

void reportRogueRoutes(
  HookContext context,
  RouteConfiguration configuration,
) {
  if (configuration.rogueRoutes.isNotEmpty) {
    context.logger.info('');
    for (final route in configuration.rogueRoutes) {
      final filePath = path.normalize(path.join('routes', route.path));
      final fileDirectory = path.dirname(filePath);
      final idealPath = path.join(
        fileDirectory,
        path.basenameWithoutExtension(filePath),
        'index.dart',
      );
      context.logger.err(
        '''Rogue route detected.${defaultForeground.wrap(' ')}Rename ${lightCyan.wrap(filePath)} to ${lightCyan.wrap(idealPath)}.''',
      );
    }
  }
}

const _asyncRunZoned = runZoned;

abstract class ExitOverrides {
  static final _token = Object();

  static ExitOverrides? get current {
    return Zone.current[_token] as ExitOverrides?;
  }

  static R runZoned<R>(R Function() body, {void Function(int)? exit}) {
    final overrides = _ExitOverridesScope(exit);
    return _asyncRunZoned(body, zoneValues: {_token: overrides});
  }

  void Function(int exitCode) get exit => io.exit;
}

class _ExitOverridesScope extends ExitOverrides {
  _ExitOverridesScope(this._exit);

  final ExitOverrides? _previous = ExitOverrides.current;
  final void Function(int exitCode)? _exit;

  @override
  void Function(int exitCode) get exit {
    return _exit ?? _previous?.exit ?? super.exit;
  }
}
