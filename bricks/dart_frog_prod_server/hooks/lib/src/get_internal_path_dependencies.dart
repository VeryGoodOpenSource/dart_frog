import 'dart:io' as io;

import 'package:dart_frog_prod_server_hooks/dart_frog_prod_server_hooks.dart';
import 'package:path/path.dart' as path;

Future<List<String>> getInternalPathDependencies(io.Directory directory) async {
  final pubspecLock = await getPubspecLock(directory.path);
  return pubspecLock.packages
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
    return path.isWithin('', dependencyPath);
  }).toList();
}
