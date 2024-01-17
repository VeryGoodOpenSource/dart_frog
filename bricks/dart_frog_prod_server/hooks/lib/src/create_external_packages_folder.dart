import 'dart:io';

import 'package:dart_frog_prod_server_hooks/dart_frog_prod_server_hooks.dart';
import 'package:io/io.dart' as io;
import 'package:path/path.dart' as path;

Future<List<String>> createExternalPackagesFolder(
  Directory directory, {
  path.Context? pathContext,
  Future<void> Function(String from, String to) copyPath = io.copyPath,
}) async {
  final pathResolver = pathContext ?? path.context;
  final pubspecLock = await getPubspecLock(
    directory.path,
    pathContext: pathResolver,
  );

  final externalPathDependencies = pubspecLock.packages
      .map(
        (p) => p.iswitch(
          sdk: (_) => null,
          hosted: (_) => null,
          git: (_) => null,
          path: (d) => d.path,
        ),
      )
      .whereType<String>()
      .where((dependencyPath) {
    return !pathResolver.isWithin('', dependencyPath);
  }).toList();

  if (externalPathDependencies.isEmpty) {
    return [];
  }
  final mappedDependencies = externalPathDependencies
      .map(
    (dependencyPath) => (
      pathResolver.basename(dependencyPath),
      dependencyPath,
    ),
  )
      .fold(<String, String>{}, (map, dependency) {
    map[dependency.$1] = dependency.$2;
    return map;
  });

  final buildDirectory = Directory(
    pathResolver.join(
      directory.path,
      'build',
    ),
  )..createSync();

  final packagesDirectory = Directory(
    pathResolver.join(
      buildDirectory.path,
      '.dart_frog_path_dependencies',
    ),
  )..createSync();

  final copiedPaths = <String>[];
  for (final entry in mappedDependencies.entries) {
    final from = pathResolver.join(directory.path, entry.value);
    final to = pathResolver.join(packagesDirectory.path, entry.key);

    await copyPath(from, to);
    copiedPaths.add(
      path.relative(to, from: buildDirectory.path),
    );
  }

  final mappedPaths = mappedDependencies.map(
    (key, value) => MapEntry(
      key,
      pathResolver.relative(
        path.join(packagesDirectory.path, key),
        from: buildDirectory.path,
      ),
    ),
  );

  await File(
    pathResolver.join(
      buildDirectory.path,
      'pubspec_overrides.yaml',
    ),
  ).writeAsString('''
dependency_overrides:
${mappedPaths.entries.map((entry) => '  ${entry.key}:\n    path: ${entry.value}').join('\n')}
''');

  return copiedPaths;
}
