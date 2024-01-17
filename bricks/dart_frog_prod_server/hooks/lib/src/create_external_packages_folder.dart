import 'dart:io';

import 'package:dart_frog_prod_server_hooks/dart_frog_prod_server_hooks.dart';
import 'package:io/io.dart' as io;
import 'package:path/path.dart' as path;

Future<List<Map<String, dynamic>>> createExternalPackagesFolder({
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
      path: (d) => _DartPackage(name: p.package(), path: d.path),
    ),
  );
  final externalPathDependencies =
      pathDependencies.whereType<_DartPackage>().where((dependency) {
    return !pathResolver.isWithin('', dependency.path);
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
    final from = pathResolver.relative(
      dependency.path,
      from: projectDirectory.path,
    );
    final to = pathResolver.join(packagesDirectory.path, dependency.name);

    await copyPath(from, to);

    final copiedPackage = _DartPackage(
      name: dependency.name,
      path: path.relative(to, from: buildDirectory.path),
    );
    copiedExternalPathDependencies.add(copiedPackage);
  }

  return copiedExternalPathDependencies
      .map((dependency) => dependency.toJson())
      .toList();
}

class _DartPackage {
  const _DartPackage({
    required this.name,
    required this.path,
  });

  final String name;
  final String path;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
    };
  }
}
