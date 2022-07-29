import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dart_frog_cli/src/commands/commands.dart';
import 'package:dart_frog_cli/src/version.dart';
import 'package:mason/mason.dart' hide packageVersion;

/// The package name.
const packageName = 'dart_frog_cli';

/// The executable name.
const executableName = 'dart_frog';

/// The executable description.
const executableDescription =
    'A fast, minimalistic backend framework for Dart.';

/// {@template dart_frog_command_runner}
/// A [CommandRunner] for the Dart Frog CLI.
/// {@endtemplate}
class DartFrogCommandRunner extends CommandRunner<int> {
  /// {@macro dart_frog_command_runner}
  DartFrogCommandRunner({
    Logger? logger,
  })  : _logger = logger ?? Logger(),
        super(executableName, executableDescription) {
    argParser.addFlags();
    addCommand(BuildCommand(logger: _logger));
    addCommand(CreateCommand(logger: _logger));
    addCommand(DevCommand(logger: _logger));
  }

  final Logger _logger;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      return await runCommand(parse(args)) ?? ExitCode.success.code;
    } catch (error) {
      _logger.err('$error');
      return ExitCode.software.code;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults['version'] == true) {
      _logger.info(packageVersion);
      return ExitCode.success.code;
    }
    if (topLevelResults['verbose'] == true) {
      _logger.level = Level.verbose;
    }
    return super.runCommand(topLevelResults);
  }
}

extension on ArgParser {
  void addFlags() {
    addFlag(
      'version',
      negatable: false,
      help: 'Print the current version.',
    );
    addFlag(
      'verbose',
      negatable: false,
      help: 'Output additional logs.',
    );
  }
}
