import 'dart:io';

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

Future<void> run(HookContext context) async {
  final projectDirectory = Directory.current;
  final buildDirectoryPath = path.join(projectDirectory.path, 'build');
  final buildDirectory = Directory(buildDirectoryPath);
  final dartFrogDirectoryPath = path.join(projectDirectory.path, '.dart_frog');
  final dartFrogDirectory = Directory(dartFrogDirectoryPath);

  final bundlingDone = context.logger.progress('Bundling sources');
  if (await buildDirectory.exists()) {
    await buildDirectory.delete(recursive: true);
  }

  if (await dartFrogDirectory.exists()) {
    await dartFrogDirectory.delete(recursive: true);
  }

  final tempDirectory = await Directory.systemTemp.createTemp();
  final result = await Process.run(
    'cp',
    ['-rf', '.', '${tempDirectory.path}${path.separator}'],
    workingDirectory: projectDirectory.path,
    runInShell: true,
  );
  bundlingDone();

  if (result.exitCode != 0) throw Exception('${result.stderr}');

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
  };
}
