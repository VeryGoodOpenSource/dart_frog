// ignore_for_file: public_member_api_docs

import 'package:dart_frog_cli/src/command.dart';
import 'package:dart_frog_cli/src/daemon/daemon.dart';

class DaemonCommand extends DartFrogCommand {
  @override
  String get description => 'Start dart frog daemon';

  @override
  String get name => 'daemon';

  @override
  Future<int> run() async {
    final daemon = Daemon(DaemonConnection.fromStdio());
    final exit = await daemon.exitCode;
    return exit.code;
  }
}
