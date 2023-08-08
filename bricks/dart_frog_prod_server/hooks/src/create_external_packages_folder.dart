import 'dart:io';

import 'package:io/io.dart';
import 'package:path/path.dart' as path;

import 'get_path_dependencies.dart';

Future<List<String>> createExternalPackagesFolder(Directory directory) async {
  // Get all the dependencies
  final pathDependencies = await _getExternalDependencies(directory);

  if (pathDependencies.isNotEmpty) {
    // Make sure the is no repeated dependencies, giving preference
    // to the shortest path.
    final mappedDependencies = pathDependencies
        .map(
      (dependencyPath) => (path.basename(dependencyPath), dependencyPath),
    )
        .fold(<String, String>{}, (map, dependency) {
      if ((map[dependency.$1]?.length ?? double.infinity) >
          dependency.$2.length) {
        map[dependency.$1] = dependency.$2;
      }

      return map;
    });

    final buildDirectory = Directory(
      path.join(
        directory.path,
        'build',
      ),
    )..createSync();

    // Create the packages directory
    final packagesDirectory = Directory(
      path.join(
        buildDirectory.path,
        '.dart_frog_path_dependencies',
      ),
    )..createSync();

    // Copy all the dependencies to the packages directory
    for (final entry in mappedDependencies.entries) {
      final from = path.join(directory.path, entry.value);
      final to = path.join(packagesDirectory.path, entry.key);

      await copyPath(from, to);
    }

    final mappedPaths = mappedDependencies.map(
      (key, value) => MapEntry(
        key,
        path.relative(
          path.join(packagesDirectory.path, key),
          from: buildDirectory.path,
        ),
      ),
    );

    await File(
      path.join(
        buildDirectory.path,
        'pubspec_overrides.yaml',
      ),
    ).writeAsString('''
dependency_overrides:
${mappedPaths.entries.map((entry) => '  ${entry.key}:\n    path: ${entry.value}').join('\n')}
''');

    return mappedPaths.values.toList();
  }

  return [];
}

Future<List<String>> _getExternalDependencies(Directory directory) async {
  final dependencies = await getPathDependencies(directory);

  final toAdd = <String>[];
  for (final dependency in dependencies) {
    final dependencyDirectory = Directory(
      path.join(directory.path, dependency),
    );

    final relativePath =
        path.relative(dependencyDirectory.path, from: directory.path);
    final innerDependencies = await getPathDependencies(dependencyDirectory);
    toAdd.addAll(
      innerDependencies
          .where((dependencyPath) => dependencyPath.startsWith('..'))
          .map((innerDependency) => path.join(relativePath, innerDependency)),
    );
  }

  dependencies.addAll(toAdd);

  return dependencies;
}
