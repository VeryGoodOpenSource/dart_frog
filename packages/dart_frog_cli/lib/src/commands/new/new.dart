import 'package:args/command_runner.dart';
import 'package:dart_frog_cli/src/command.dart';
import 'package:dart_frog_cli/src/commands/commands.dart';
import 'package:dart_frog_cli/src/commands/new/templates/new_route_bundle.dart';
import 'package:mason/mason.dart';

class NewCommand extends DartFrogCommand {
  NewCommand({
    super.logger,
    GeneratorBuilder? generator,
  }) : _generator = generator ?? MasonGenerator.fromBundle {
    addSubcommand(NewRouteCommand());
  }

  final GeneratorBuilder _generator;

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
  NewCommand get parent => super.parent! as NewCommand;

  String get _routeName {
    final routeName = argResults!.rest.first;
    if (routeName.isEmpty) {
      throw UsageException('route name must not be empty', usageString);
    }
    //todo(renancaraujo): validate route name
    return routeName;
  }

  @override
  Future<int> run() async {
    final routeName = _routeName;

    final generator = await parent._generator(newRouteBundle);

    final generateProgress = logger.progress('Creating route $routeName');

    final vars = <String, dynamic>{
      'route': routeName,
    };

    // todo: validate if there is any routes directory here

    await generator.hooks.preGen(
      vars: vars,
      workingDirectory: cwd.path,
      onVarsChanged: vars.addAll,
    );
    final _ = await generator.generate(
      DirectoryGeneratorTarget(cwd),
      vars: vars,
    );
    await generator.hooks.postGen(vars: vars, workingDirectory: cwd.path);
    generateProgress.complete();

    return ExitCode.success.code;
  }
}
