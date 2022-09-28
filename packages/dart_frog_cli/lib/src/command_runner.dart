import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dart_frog_cli/src/commands/commands.dart';
import 'package:dart_frog_cli/src/commands/update/update.dart';
import 'package:dart_frog_cli/src/version.dart';
import 'package:mason/mason.dart' hide packageVersion;
import 'package:pub_updater/pub_updater.dart';

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
    PubUpdater? pubUpdater,
  })  : _logger = logger ?? Logger(),
        _pubUpdater = pubUpdater ?? PubUpdater(),
        super(executableName, executableDescription) {
    argParser.addFlags();
    addCommand(BuildCommand(logger: _logger));
    addCommand(CreateCommand(logger: _logger));
    addCommand(DevCommand(logger: _logger));
    addCommand(UpdateCommand(logger: _logger));
  }

  final Logger _logger;
  final PubUpdater _pubUpdater;

  @override
  Future<int> run(Iterable<String> args) async {
    final argResults = parse(args);
    late final int exitCode;

    try {
      exitCode = await runCommand(argResults) ?? ExitCode.success.code;
    } catch (error) {
      _logger.err('$error');
      exitCode = ExitCode.software.code;
    }

    if (argResults.command?.name != 'update') await _checkForUpdates();

    return exitCode;
  }

  Future<void> _checkForUpdates() async {
    try {
      final latestVersion = await _pubUpdater.getLatestVersion(packageName);
      final isUpToDate = packageVersion == latestVersion;
      if (!isUpToDate) {
        final changelogLink = lightCyan.wrap(
          styleUnderlined.wrap(
            link(
              uri: Uri.parse(
                'https://github.com/verygoodopensource/dart_frog/releases/tag/dart_frog_cli-v$latestVersion',
              ),
            ),
          ),
        );
        _logger
          ..info('')
          ..info(
            '''
${lightYellow.wrap('Update available!')} ${lightCyan.wrap(packageVersion)} \u2192 ${lightCyan.wrap(latestVersion)}
${lightYellow.wrap('Changelog:')} $changelogLink
Run ${lightCyan.wrap('$executableName update')} to update''',
          );
      }
    } catch (_) {}
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

    _logger.detail('[meta] $packageName $packageVersion');
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
