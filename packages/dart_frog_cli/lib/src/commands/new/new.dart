import 'package:dart_frog_cli/src/command.dart';
import 'package:mason/mason.dart';

class NewCommand extends DartFrogCommand {
  NewCommand({
    super.logger,
  }) {
    addSubcommand(NewRouteCommand());
  }

  @override
  String get description => 'Create a new route or middleware for dart_frog';

  @override
  String get name => 'new';
}

class NewRouteCommand extends DartFrogCommand {
  @override
  String get description => 'Create a new route for dart_frog';

  @override
  String get name => 'route';

  @override
  Future<int> run() async {
    print('new route');

    return ExitCode.success.code;
  }
}
