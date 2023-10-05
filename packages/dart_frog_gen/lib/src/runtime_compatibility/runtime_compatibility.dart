import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';

/// Type definition for [ensureRuntimeCompatibility].
typedef RuntimeCompatibilityCallback = void Function(Directory cwd);

/// {@template dart_frog_compatibility_exception}
/// An exception thrown when the current version of dart_frog_cli
/// is incompatible with the dart_frog runtime being used.
/// {@endtemplate}
class DartFrogCompatibilityException implements Exception {
  /// {@macro dart_frog_compatibility_exception}
  const DartFrogCompatibilityException(this.message);

  /// The exception message.
  final String message;

  @override
  String toString() => message;
}

/// The version range of package:dart_frog
/// supported by the current version of package:dart_frog_cli.
const compatibleDartFrogVersion = '>=1.0.0 <2.0.0';

/// Whether current version of package:dart_frog_cli is compatible
/// with the provided [version] of package:dart_frog.
bool isCompatibleWithDartFrog(VersionConstraint version) {
  return VersionConstraint.parse(compatibleDartFrogVersion).allowsAll(version);
}

/// Ensures that the current version of `package:dart_frog_cli` is compatible
/// with the version of `package:dart_frog` used in the [cwd].
void ensureRuntimeCompatibility(Directory cwd) {
  final pubspecFile = File(path.join(cwd.path, 'pubspec.yaml'));
  if (!pubspecFile.existsSync()) {
    throw DartFrogCompatibilityException(
      'Expected to find a pubspec.yaml in ${cwd.path}.',
    );
  }

  final pubspec = Pubspec.parse(pubspecFile.readAsStringSync());
  final dependencyEntry = pubspec.dependencies.entries.where(
    (e) => e.key == 'dart_frog',
  );

  if (dependencyEntry.isEmpty) {
    throw const DartFrogCompatibilityException(
      'Expected to find a dependency on "dart_frog" in the pubspec.yaml',
    );
  }

  final dependency = dependencyEntry.first.value;
  if (dependency is HostedDependency) {
    if (!isCompatibleWithDartFrog(dependency.version)) {
      throw DartFrogCompatibilityException(
        '''The current version of "dart_frog_cli" requires "dart_frog" $compatibleDartFrogVersion.\nBecause the current version of "dart_frog" is ${dependency.version}, version solving failed.''',
      );
    }
  }
}
