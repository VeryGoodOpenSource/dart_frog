import 'dart:io';

import 'package:io/io.dart' as io;
import 'package:path/path.dart' as path;
import 'package:pubspec_lock/pubspec_lock.dart';

Future<List<String>> createExternalPackagesFolder(
  Directory directory, {
  path.Context? pathContext,
  Future<void> Function(String from, String to) copyPath = io.copyPath,
}) async {
  final pathResolver = pathContext ?? path.context;
  final pubspecLock = await _getPubspecLock(directory.path, pathResolver);

  final pathDependencies = pubspecLock.packages
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

  if (pathDependencies.isNotEmpty) {
    // Map the dependencies
    final mappedDependencies = pathDependencies
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

    // Create the packages directory
    final packagesDirectory = Directory(
      pathResolver.join(
        buildDirectory.path,
        '.dart_frog_path_dependencies',
      ),
    )..createSync();

    // Copy all the dependencies to the packages directory
    for (final entry in mappedDependencies.entries) {
      final from = pathResolver.join(directory.path, entry.value);
      final to = pathResolver.join(packagesDirectory.path, entry.key);

      await copyPath(from, to);
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

    return mappedPaths.values.toList();
  }

  return [];
}

Future<PubspecLock> _getPubspecLock(
    String workingDirectory, path.Context pathResolver) async {
  final pubspecLockFile = File(
    workingDirectory.isEmpty
        ? 'pubspec.lock'
        : pathResolver.join(workingDirectory, 'pubspec.lock'),
  );

  final content = await pubspecLockFile.readAsString();
  return content.loadPubspecLockFromYaml();
}
