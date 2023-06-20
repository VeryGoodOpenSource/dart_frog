import 'dart:async';

import 'package:mason/mason.dart';

/// {@template daemon}
/// The Dart Frog daemon.
///
/// The daemon is a persistent routine that runs, analyzes and manages
/// Dart Frog projects.
/// {@endtemplate}
class Daemon {
  /// {@macro daemon}
  Daemon({
    Logger? logger,
  }) : _logger = logger ?? Logger() {
    // TODO(renancaraujo): this is just a placeholder behavior.
    _logger.detail('Starting Dart Frog daemon...');
    Future<void>.delayed(const Duration(seconds: 2)).then(
      (_) {
        _logger.detail('Killing Dart Frog daemon...');
        kill(ExitCode.success);
      },
    );
  }

  final Logger _logger;

  final  _exitCodeCompleter = Completer<ExitCode>();

  /// A [Future] that completes when the daemon exits.
  Future<ExitCode> get exitCode => _exitCodeCompleter.future;

  /// Kills the daemon with the given [exitCode].
  void kill(ExitCode exitCode) {
    if (_exitCodeCompleter.isCompleted) return;
    _exitCodeCompleter.complete(exitCode);
  }
}
