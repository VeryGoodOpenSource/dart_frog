// ignore_for_file: no_adjacent_strings_in_list
import 'dart:async';
import 'dart:io';

import 'package:dart_frog_cli/src/command_runner.dart';
import 'package:dart_frog_cli/src/version.dart';
import 'package:mason/mason.dart' hide packageVersion;
import 'package:mocktail/mocktail.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:test/test.dart';

class _MockLogger extends Mock implements Logger {}

class _MockPubUpdater extends Mock implements PubUpdater {}

class _MockProcessSignal extends Mock implements ProcessSignal {}

const expectedUsage = [
  'A fast, minimalistic backend framework for Dart.\n'
      '\n'
      'Usage: dart_frog <command> [arguments]\n'
      '\n'
      'Global options:\n'
      '-h, --help       Print this usage information.\n'
      '    --version    Print the current version.\n'
      '    --verbose    Output additional logs.\n'
      '\n'
      'Available commands:\n'
      '  build    Create a production build.\n'
      '  create   Creates a new Dart Frog app.\n'
      '  dev      Run a local development server.\n'
      '  update   Update the Dart Frog CLI.\n'
      '\n'
      'Run "dart_frog help <command>" for more information about a command.'
];

const latestVersion = '0.0.0';
final changelogLink = lightCyan.wrap(
  styleUnderlined.wrap(
    link(
      uri: Uri.parse(
        'https://github.com/verygoodopensource/dart_frog/releases/tag/dart_frog_cli-v$latestVersion',
      ),
    ),
  ),
);
final updateMessage = '''
${lightYellow.wrap('Update available!')} ${lightCyan.wrap(packageVersion)} \u2192 ${lightCyan.wrap(latestVersion)}
${lightYellow.wrap('Changelog:')} $changelogLink
Run ${lightCyan.wrap('$executableName update')} to update''';

void main() {
  group('DartFrogCommandRunner', () {
    late Logger logger;
    late PubUpdater pubUpdater;
    late DartFrogCommandRunner commandRunner;
    late ProcessSignal sigint;

    setUp(() {
      printLogs = [];
      logger = _MockLogger();
      pubUpdater = _MockPubUpdater();
      sigint = _MockProcessSignal();

      when(
        () => pubUpdater.getLatestVersion(any()),
      ).thenAnswer((_) async => packageVersion);

      when(() => sigint.watch()).thenAnswer((_) => const Stream.empty());

      commandRunner = DartFrogCommandRunner(
        logger: logger,
        pubUpdater: pubUpdater,
        exit: (_) {},
        sigint: sigint,
      );
    });

    test('can be instantiated without any explicit parameters', () {
      final commandRunner = DartFrogCommandRunner();
      expect(commandRunner, isNotNull);
    });

    group('run', () {
      test('checks for updates on sigint', () async {
        final exitCalls = <int>[];
        commandRunner = DartFrogCommandRunner(
          logger: logger,
          pubUpdater: pubUpdater,
          exit: exitCalls.add,
          sigint: sigint,
        );
        when(() => sigint.watch()).thenAnswer((_) => Stream.value(sigint));
        await commandRunner.run(['--version']);
        expect(exitCalls, equals([0]));
        verify(() => pubUpdater.getLatestVersion(any())).called(2);
      });

      test('prompts for update when newer version exists', () async {
        when(
          () => pubUpdater.getLatestVersion(any()),
        ).thenAnswer((_) async => latestVersion);
        final result = await commandRunner.run(['--version']);
        expect(result, equals(ExitCode.success.code));
        verify(() => logger.info(updateMessage)).called(1);
      });

      test('handles pub update errors gracefully', () async {
        when(
          () => pubUpdater.getLatestVersion(any()),
        ).thenThrow(Exception('oops'));

        final result = await commandRunner.run(['--version']);
        expect(result, equals(ExitCode.success.code));
        verifyNever(() => logger.info(updateMessage));
      });

      test('handles Exception', () async {
        final exception = Exception('oops!');
        var isFirstInvocation = true;
        when(() => logger.info(any())).thenAnswer((_) {
          if (isFirstInvocation) {
            isFirstInvocation = false;
            throw exception;
          }
        });
        final result = await commandRunner.run(['--version']);
        expect(result, equals(ExitCode.software.code));
        verify(() => logger.err('$exception')).called(1);
      });

      test(
        'handles no command',
        overridePrint(() async {
          final result = await commandRunner.run([]);
          expect(printLogs, equals(expectedUsage));
          expect(result, equals(ExitCode.success.code));
        }),
      );

      group('--help', () {
        test(
          'outputs usage',
          overridePrint(() async {
            final result = await commandRunner.run(['--help']);
            expect(printLogs, equals(expectedUsage));
            expect(result, equals(ExitCode.success.code));

            printLogs.clear();

            final resultAbbr = await commandRunner.run(['-h']);
            expect(printLogs, equals(expectedUsage));
            expect(resultAbbr, equals(ExitCode.success.code));
          }),
        );
      });

      group('--verbose', () {
        test(
          'sets correct log level.',
          overridePrint(() async {
            await commandRunner.run(['--verbose']);
            verify(() => logger.level = Level.verbose).called(1);
          }),
        );

        test(
          'outputs correct meta info',
          overridePrint(() async {
            await commandRunner.run(['--verbose']);
            verify(
              () => logger.detail('[meta] dart_frog_cli $packageVersion'),
            ).called(1);
          }),
        );
      });

      group('--version', () {
        test('outputs current version', () async {
          final result = await commandRunner.run(['--version']);
          expect(result, equals(ExitCode.success.code));
          verify(() => logger.info(packageVersion)).called(1);
        });
      });
    });
  });
}

List<String> printLogs = <String>[];

void Function() overridePrint(void Function() fn) {
  return () {
    final spec = ZoneSpecification(
      print: (_, __, ___, String msg) {
        printLogs.add(msg);
      },
    );
    return Zone.current.fork(specification: spec).run<void>(fn);
  };
}
