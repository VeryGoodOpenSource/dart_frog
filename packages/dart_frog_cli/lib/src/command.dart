import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dart_frog_cli/src/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';

/// {@template dart_frog_command}
/// The base class for all dart_frog_cli executable commands.
/// {@endtemplate}
abstract class DartFrogCommand extends Command<int> {
  /// {@macro dart_frog_command}
  DartFrogCommand({Logger? logger}) : _logger = logger;

  /// [ArgResults] used for testing purposes only.
  @visibleForTesting
  ArgResults? testArgResults;

  /// Usage [String] used for testing purposes only.
  @visibleForTesting
  String? testUsage;

  /// Current working directory used for testing purposes only.
  Directory? testCwd;

  /// [stdin] used for testing purposes only.
  Stdin? testStdin;

  /// The [Stdin] instance to be used by the commands.
  Stdin get stdin => testStdin ?? (runner as DartFrogCommandRunner?)!.stdin;

  /// [ArgResults] for the current command.
  ArgResults get results => testArgResults ?? argResults!;

  /// Usage string.
  String get usageString => testUsage ?? usage;

  /// [Logger] instance used to wrap stdout.
  Logger get logger => _logger ??= Logger();

  Logger? _logger;

  /// Return the current working directory.
  Directory get cwd => testCwd ?? Directory.current;
}
