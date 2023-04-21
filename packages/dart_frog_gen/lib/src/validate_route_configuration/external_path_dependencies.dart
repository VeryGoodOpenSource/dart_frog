import 'dart:io' as io;

import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';

/// Type definition for callbacks that report external path dependencies.
typedef OnExternalPathDependency = void Function(
  String dependencyName,
  String dependencyPath,
);

/// Reports existence of external path dependencies on a [Directory].
Future<void> reportExternalPathDependencies(
  io.Directory directory, {
  /// Callback called when any external path dependency is found.
  void Function()? onViolationStart,

  /// Callback called for each external path dependency found.
  OnExternalPathDependency? onExternalPathDependency,

  /// Callback called when any external path dependency is found.
  void Function()? onViolationEnd,
}) async {
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
    onViolationStart?.call();
    for (final dependency in externalDependencies) {
      final dependencyName = dependency.first;
      final dependencyPath = path.normalize(dependency.last);
      onExternalPathDependency?.call(dependencyName, dependencyPath);
    }
    onViolationEnd?.call();
  }
}
