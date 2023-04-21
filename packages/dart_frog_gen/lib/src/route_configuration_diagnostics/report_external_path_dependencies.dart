import 'dart:io' as io;

import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';

typedef OnExternalPathDependency = void Function(
  String dependencyName,
  String dependencyPath,
);

Future<void> reportExternalPathDependencies(
  io.Directory directory, {
  required OnExternalPathDependency onExternalPathDependency,
  void Function()? onViolation,
  void Function()? onExit,
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
    onViolation?.call();
    for (final dependency in externalDependencies) {
      final dependencyName = dependency.first;
      final dependencyPath = path.normalize(dependency.last);
      onExternalPathDependency.call(dependencyName, dependencyPath);
    }
    onExit?.call();
  }
}
