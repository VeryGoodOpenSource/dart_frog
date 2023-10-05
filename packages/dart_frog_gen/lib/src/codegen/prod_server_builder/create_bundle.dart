// ignore_for_file: public_member_api_docs, only_throw_errors

import 'dart:io' as io;

import 'package:io/io.dart' show copyPath;
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

Future<void> createBundle(
  Logger logger,
  io.Directory projectDirectory,
) async {
  final buildDirectoryPath = path.join(projectDirectory.path, 'build');
  final buildDirectory = io.Directory(buildDirectoryPath);
  final dartFrogDirectoryPath = path.join(projectDirectory.path, '.dart_frog');
  final dartFrogDirectory = io.Directory(dartFrogDirectoryPath);
  final bundlingProgress = logger.progress('Bundling sources');
  final tempDirectory = await io.Directory.systemTemp.createTemp();

  if (buildDirectory.existsSync()) {
    await buildDirectory.delete(recursive: true);
  }

  if (dartFrogDirectory.existsSync()) {
    await dartFrogDirectory.delete(recursive: true);
  }

  try {
    await copyPath(
      projectDirectory.path,
      '${tempDirectory.path}${path.separator}',
    );
    bundlingProgress.complete();
  } catch (error) {
    bundlingProgress.fail();
    logger.err('$error');
    throw 'oppsie';
  }
  await copyPath(tempDirectory.path, buildDirectory.path);
}
