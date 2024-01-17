import 'dart:io';

import 'package:dart_frog_prod_server_hooks/dart_frog_prod_server_hooks.dart';
import 'package:io/io.dart' as io;
import 'package:path/path.dart' as path;

Future<List<String>> createExternalPackagesFolder({
  required Directory projectDirectory,
  required Directory buildDirectory,
  Future<void> Function(String from, String to) copyPath = io.copyPath,
}) async {
  final pathResolver = path.context;
  final pubspecLock = await getPubspecLock(
    projectDirectory.path,
    pathContext: path.context,
  );

  final pathDependencies = pubspecLock.packages.map(
    (p) => p.iswitch(
      sdk: (_) => null,
      hosted: (_) => null,
      git: (_) => null,
      path: (d) => _DartPackage(
        name: p.package(),
        packagePath: d.path,
      ),
    ),
  );
  final externalPathDependencies =
      pathDependencies.whereType<_DartPackage>().where((dependency) {
    return !pathResolver.isWithin('', dependency.packagePath);
  }).toList();

  if (externalPathDependencies.isEmpty) {
    return [];
  }

  final buildDirectory = Directory(
    pathResolver.join(
      projectDirectory.path,
      'build',
    ),
  )..createSync();

  final packagesDirectory = Directory(
    pathResolver.join(
      buildDirectory.path,
      '.dart_frog_path_dependencies',
    ),
  )..createSync();

  final copiedExternalPathDependencies = <_DartPackage>[];
  for (final dependency in externalPathDependencies) {
    final from = pathResolver.relative(dependency.packagePath,
        from: projectDirectory.path);
    final to = pathResolver.join(packagesDirectory.path, dependency.name);

    await copyPath(from, to);

    final copiedPackage = _DartPackage(
      name: dependency.name,
      packagePath: to,
    );
    copiedExternalPathDependencies.add(copiedPackage);
  }

  final dependencyOverridesFile = File(
    pathResolver.join(
      buildDirectory.path,
      'pubspec_overrides.yaml',
    ),
  );
  await dependencyOverridesFile.writeAsString('''
dependency_overrides:
${copiedExternalPathDependencies.map(
            (dependency) => dependency.asPubspecEntry(
              pubspecPath: dependencyOverridesFile.path,
            ),
          ).join('\n')}
''');

  return copiedExternalPathDependencies
      .map((dependency) => dependency.packagePath)
      .toList();
}

class _DartPackage {
  const _DartPackage({
    required this.name,
    required this.packagePath,
  });

  final String name;
  final String packagePath;

  /// Derives a [String] to be used as an entry in a `pubspec_overrides.yaml`.
  ///
  /// For example:
  /// ```yaml
  /// dependency_overrides:
  ///   my_package:
  ///     path: ../my_package
  /// ```
  String asPubspecEntry({required String pubspecPath}) {
    final relativePath = path.relative(packagePath, from: pubspecPath);
    return '  $name:\n    path: $relativePath';
  }
}
