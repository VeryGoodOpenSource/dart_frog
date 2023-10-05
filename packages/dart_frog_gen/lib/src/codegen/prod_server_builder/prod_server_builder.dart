// ignore_for_file: public_member_api_docs

import 'dart:io' as io;

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:dart_frog_gen/src/codegen/bundles/dart_frog_prod_server_bundle.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';

class ProdServerBuilder {
  ProdServerBuilder({
    required this.dartVersion,
    required this.logger,
    required this.workingDirectory,
    @visibleForTesting GeneratorBuilder? generator,
  }) : _generator = generator ?? MasonGenerator.fromBundle;

  final String dartVersion;

  /// The working directory of the dart_frog project.
  final io.Directory workingDirectory;

  final GeneratorBuilder _generator;

  /// [Logger] instance used to wrap stdout.
  final Logger logger;

  Future<ExitCode> build() async {
    var vars = <String, dynamic>{
      'dartVersion': dartVersion,
    };

    final buildBundleGenerator = await _generator(dartFrogProdServerBundle);

    logger.detail('[codegen] running pre-gen...');
    await buildBundleGenerator.hooks.preGen(
      vars: vars,
      workingDirectory: workingDirectory.path,
      onVarsChanged: (v) => vars = v,
    );

    logger.detail('[codegen] running generate...');
    final _ = await buildBundleGenerator.generate(
      DirectoryGeneratorTarget(workingDirectory),
      vars: vars,
      fileConflictResolution: FileConflictResolution.overwrite,
    );

    logger.detail('[codegen] running post-gen...');
    await buildBundleGenerator.hooks.postGen(
      workingDirectory: workingDirectory.path,
    );

    logger.detail('[codegen] complete.');
    return ExitCode.success;
  }
}
