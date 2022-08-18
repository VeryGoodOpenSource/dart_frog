import 'dart:async';
import 'dart:io' as io;

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:io/io.dart' show copyPath;
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';

typedef RouteConfigurationBuilder = RouteConfiguration Function(
  io.Directory directory,
);

Future<void> run(HookContext context) => preGen(context);

Future<void> preGen(
  HookContext context, {
  io.Directory? directory,
  RouteConfigurationBuilder buildConfiguration = buildRouteConfiguration,
  void Function(int exitCode)? exit,
}) async {
  final _exit = exit ?? ExitOverrides.current?.exit ?? io.exit;
  final projectDirectory = directory ?? io.Directory.current;

  await createBundle(context, projectDirectory, _exit);

  final RouteConfiguration configuration;
  try {
    configuration = buildConfiguration(io.Directory.current);
  } catch (error) {
    context.logger.err('$error');
    return _exit(1);
  }

  reportRouteConflicts(context, configuration, _exit);
  reportRogueRoutes(context, configuration, _exit);

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
    'invokeCustomEntrypoint': configuration.invokeCustomEntrypoint,
    'pathDependencies': await getPathDependencies(projectDirectory),
  };
}

Future<void> createBundle(
  HookContext context,
  io.Directory projectDirectory,
  void Function(int exitCode) exit,
) async {
  final buildDirectoryPath = path.join(projectDirectory.path, 'build');
  final buildDirectory = io.Directory(buildDirectoryPath);
  final dartFrogDirectoryPath = path.join(projectDirectory.path, '.dart_frog');
  final dartFrogDirectory = io.Directory(dartFrogDirectoryPath);
  final bundlingProgress = context.logger.progress('Bundling sources');
  final tempDirectory = await io.Directory.systemTemp.createTemp();

  if (buildDirectory.existsSync()) {
    await buildDirectory.delete(recursive: true);
  }

  if (dartFrogDirectory.existsSync()) {
    await dartFrogDirectory.delete(recursive: true);
  }

  try {
    await copyPath(
      projectDirectory.path,
      '${tempDirectory.path}${path.separator}',
    );
    bundlingProgress.complete();
  } catch (error) {
    bundlingProgress.fail();
    context.logger.err('$error');
    return exit(1);
  }
  await copyPath(tempDirectory.path, buildDirectory.path);
}

Future<List<String>> getPathDependencies(io.Directory directory) async {
  final pubspec = Pubspec.parse(
    await io.File(path.join(directory.path, 'pubspec.yaml')).readAsString(),
  );

  final dependencies = pubspec.dependencies;
  final devDependencies = pubspec.devDependencies;
  return [...dependencies.entries, ...devDependencies.entries]
      .where((entry) => entry.value is PathDependency)
      .map((entry) => (entry.value as PathDependency).path)
      .toList();
}

void reportRouteConflicts(
  HookContext context,
  RouteConfiguration configuration,
  void Function(int exitCode) exit,
) {
  final conflictingEndpoints =
      configuration.endpoints.entries.where((entry) => entry.value.length > 1);
  if (conflictingEndpoints.isNotEmpty) {
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
    exit(1);
  }
}

void reportRogueRoutes(
  HookContext context,
  RouteConfiguration configuration,
  void Function(int exitCode) exit,
) {
  if (configuration.rogueRoutes.isNotEmpty) {
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
    exit(1);
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
