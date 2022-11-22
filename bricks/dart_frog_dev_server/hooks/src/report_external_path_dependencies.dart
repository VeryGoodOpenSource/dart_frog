import 'dart:io' as io;

import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';

Future<void> reportExternalPathDependencies(
  HookContext context,
  io.Directory directory,
) async {
  final pubspec = Pubspec.parse(
    await io.File(path.join(directory.path, 'pubspec.yaml')).readAsString(),
  );

  final dependencies = pubspec.dependencies;
  final devDependencies = pubspec.devDependencies;
  final pathDependencies = [...dependencies.entries, ...devDependencies.entries]
      .where((entry) => entry.value is PathDependency)
      .map((entry) {
    final value = entry.value as PathDependency;
    return [entry.key, value.path];
  }).toList();
  final externalDependencies = pathDependencies.where(
    (dep) => !path.isWithin(directory.path, dep.last),
  );

  if (externalDependencies.isNotEmpty) {
    context.logger
      ..info('')
      ..err('All path dependencies must be within the project.')
      ..err('External path dependencies detected:');
    for (final dependency in externalDependencies) {
      final dependencyName = dependency.first;
      final dependencyPath = path.normalize(dependency.last);
      context.logger.err('  \u{2022} $dependencyName from $dependencyPath');
    }
  }
}
