import 'dart:io' as io;

import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';

Future<List<String>> getPathDependencies(io.Directory directory) async {
  final pubspec = Pubspec.parse(
    await io.File(path.join(directory.path, 'pubspec.yaml')).readAsString(),
  );

  final dependencies = pubspec.dependencies;
  final devDependencies = pubspec.devDependencies;
  return [...dependencies.entries, ...devDependencies.entries]
      .where((entry) => entry.value is PathDependency)
      .map((entry) => (entry.value as PathDependency).path)
      .toList();
}
