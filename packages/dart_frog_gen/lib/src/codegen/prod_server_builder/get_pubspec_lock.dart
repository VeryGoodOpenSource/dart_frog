// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:pubspec_lock/pubspec_lock.dart';

Future<PubspecLock> getPubspecLock(
  String workingDirectory, {
  path.Context? pathContext,
}) async {
  final pathResolver = pathContext ?? path.context;
  final pubspecLockFile = File(
    workingDirectory.isEmpty
        ? 'pubspec.lock'
        : pathResolver.join(workingDirectory, 'pubspec.lock'),
  );

  final content = await pubspecLockFile.readAsString();
  return content.loadPubspecLockFromYaml();
}
