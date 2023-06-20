import 'package:dart_frog_cli/src/command.dart';
import 'package:dart_frog_cli/src/daemon/daemon.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';

/// Type definition for a function which creates a [Daemon].
typedef DaemonBuilder = Daemon Function(Logger logger);

Daemon _defaultDaemonBuilder(Logger logger) => Daemon(logger: logger);

/// {@template daemon_command}
/// `dart_frog daemon` command which starts the Dart Frog daemon.
/// {@endtemplate}
class DaemonCommand extends DartFrogCommand {
  /// {@macro daemon_command}
  DaemonCommand({
    super.logger,
    DaemonBuilder? daemonBuilder,
  }) : _daemonBuilder = daemonBuilder ?? _defaultDaemonBuilder;

  final DaemonBuilder _daemonBuilder;

  @override
  String get description => 'Start the Dart Frog daemon';

  @override
  String get name => 'daemon';

  @override
  // TODO(renancaraujo): unhide this command when it's ready
  bool get hidden => true;

  /// The [Daemon] instance used by this command.
  ///
  /// Visible for testing purposes only.
  @visibleForTesting
  Daemon get daemon => _daemonBuilder(logger);

  @override
  Future<int> run() => daemon.exitCode;
}
