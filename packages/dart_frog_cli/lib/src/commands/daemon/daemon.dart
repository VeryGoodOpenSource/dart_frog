import 'package:dart_frog_cli/src/command.dart';
import 'package:dart_frog_cli/src/daemon/daemon.dart';

/// Type definition for a function which creates a [Daemon].
typedef DaemonBuilder = Daemon Function();

Daemon _defaultDaemonBuilder() => Daemon();

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

  @override
  Future<int> run() async {
    final daemon = _daemonBuilder();
    final exit = await daemon.exitCode;
    return exit.code;
  }
}
