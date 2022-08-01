// ignore_for_file: no_adjacent_strings_in_list
import 'dart:async';

import 'package:dart_frog_cli/src/command_runner.dart';
import 'package:dart_frog_cli/src/version.dart';
import 'package:mason/mason.dart' hide packageVersion;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

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
      '\n'
      'Run "dart_frog help <command>" for more information about a command.'
];

void main() {
  group('DartFrogCommandRunner', () {
    late Logger logger;
    late DartFrogCommandRunner commandRunner;

    setUp(() {
      printLogs = [];
      logger = MockLogger();
      commandRunner = DartFrogCommandRunner(
        logger: logger,
      );
    });

    test('can be instantiated without an explicit logger instance', () {
      final commandRunner = DartFrogCommandRunner();
      expect(commandRunner, isNotNull);
    });

    group('run', () {
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
            final logger = Logger();
            await DartFrogCommandRunner(logger: logger).run(['--verbose']);
            expect(logger.level, equals(Level.verbose));
          }),
        );

        test(
          'outputs correct package info',
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
