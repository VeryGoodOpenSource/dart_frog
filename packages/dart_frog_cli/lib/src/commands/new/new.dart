import 'package:args/command_runner.dart';
import 'package:dart_frog_cli/src/command.dart';
import 'package:dart_frog_cli/src/commands/commands.dart';
import 'package:dart_frog_cli/src/commands/new/templates/dart_frog_new_bundle.dart';
import 'package:mason/mason.dart';

class NewCommand extends DartFrogCommand {
  NewCommand({
    super.logger,
    GeneratorBuilder? generator,
  }) : _generator = generator ?? MasonGenerator.fromBundle {
    addSubcommand(NewSubCommand('route'));
    addSubcommand(NewSubCommand('middleware'));
  }

  final GeneratorBuilder _generator;

  @override
  String get description => 'Create a new route or middleware for dart_frog';

  @override
  String get name => 'new';
}

class NewSubCommand extends DartFrogCommand {
  NewSubCommand(this.name);

  @override
  String get description => 'Create a new $name for dart_frog';

  @override
  final String name;

  @override
  NewCommand get parent => super.parent! as NewCommand;

  @override
  late final String invocation = 'dart_frog new $name "path/to/route"';

  String get _routePath {
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      throw UsageException(
        'Provide a route path for the new $name',
        usageString,
      );
    }
    final routeName = argResults!.rest.first;
    if (routeName.isEmpty) {
      throw UsageException('Route path must not be empty', usageString);
    }

    // todo(renancaraujo): validate route path
    // - (valid dart identifier on every paramater)
    // - (only ascii troughout the thing}
    // - (no $)
    // - (no empty segments)

    return routeName;
  }

  @override
  Future<int> run() async {
    final routePath = _routePath;

    final generator = await parent._generator(dartFrogNewBundle);

    final generateProgress = logger.progress('Creating $name $routePath');

    final vars = <String, dynamic>{
      'route_path': routePath,
      'type': name,
    };

    // todo(renancaraujo): validate if there is a "routes" directory here

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
