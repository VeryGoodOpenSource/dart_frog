import 'dart:io';

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:io/io.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';

Future<void> run(HookContext context) async {
  final projectDirectory = Directory.current;
  final buildDirectoryPath = path.join(projectDirectory.path, 'build');
  final buildDirectory = Directory(buildDirectoryPath);
  final dartFrogDirectoryPath = path.join(projectDirectory.path, '.dart_frog');
  final dartFrogDirectory = Directory(dartFrogDirectoryPath);

  final pubspec = Pubspec.parse(
    await File(path.join(projectDirectory.path, 'pubspec.yaml')).readAsString(),
  );

  final dependencies = pubspec.dependencies;
  final devDependencies = pubspec.devDependencies;
  final pathDependencies = [
    ...dependencies.entries,
    ...devDependencies.entries,
  ]
      .where((entry) => entry.value is PathDependency)
      .map((entry) => (entry.value as PathDependency).path)
      .toList();

  final bundlingDone = context.logger.progress('Bundling sources');
  if (await buildDirectory.exists()) {
    await buildDirectory.delete(recursive: true);
  }

  if (await dartFrogDirectory.exists()) {
    await dartFrogDirectory.delete(recursive: true);
  }

  final tempDirectory = await Directory.systemTemp.createTemp();
  try {
    await copyPath('.', '${tempDirectory.path}${path.separator}');
  } catch (error) {
    bundlingDone();
    context.logger.err('$error');
    exit(1);
  }

  bundlingDone();

  await tempDirectory.rename(buildDirectoryPath);

  final RouteConfiguration configuration;
  try {
    configuration = buildRouteConfiguration(Directory.current);
  } catch (error) {
    context.logger.err('$error');
    exit(1);
  }

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
    'pathDependencies': pathDependencies,
  };
}
