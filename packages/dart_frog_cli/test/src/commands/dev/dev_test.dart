import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_frog_cli/src/commands/commands.dart';
import 'package:dart_frog_cli/src/dev_server_runner/dev_server_runner.dart';
import 'package:dart_frog_cli/src/runtime_compatibility.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockArgResults extends Mock implements ArgResults {}

class _MockLogger extends Mock implements Logger {}

class _MockMasonGenerator extends Mock implements MasonGenerator {}

class _MockDevServerRunner extends Mock implements DevServerRunner {}

void main() {
  group('dart_frog dev', () {
    late ArgResults argResults;
    late MasonGenerator generator;
    late DevServerRunner runner;
    late Logger logger;

    setUp(() {
      argResults = _MockArgResults();
      generator = _MockMasonGenerator();
      runner = _MockDevServerRunner();
      logger = _MockLogger();

      when<dynamic>(() => argResults['port']).thenReturn('8080');
      when<dynamic>(() => argResults['dart-vm-service-port'])
          .thenReturn('8181');
    });

    test('can be instantiated', () {
      final command = DevCommand();
      expect(command, isNotNull);
    });

    test('throws if ensureRuntimeCompatibility fails', () {
      final command = DevCommand(
        generator: (_) async => generator,
        ensureRuntimeCompatibility: (_) {
          throw const DartFrogCompatibilityException('oops');
        },
        devServerRunnerBuilder: ({
          required logger,
          required port,
          required devServerBundleGenerator,
          required dartVmServicePort,
          required workingDirectory,
          void Function()? onHotReloadEnabled,
        }) {
          return runner;
        },
        logger: logger,
      )..testArgResults = argResults;

      expect(
        command.run(),
        throwsA(isA<DartFrogCompatibilityException>()),
      );
    });

    test('run the dev server with the given parameters', () async {
      when(() => runner.start()).thenAnswer((_) => Future.value());
      when(() => runner.exitCode).thenAnswer(
        (_) => Future.value(ExitCode.success),
      );

      when(() => argResults['port']).thenReturn('1234');
      when(() => argResults['dart-vm-service-port']).thenReturn('5678');

      final cwd = Directory.systemTemp;

      late String givenPort;
      late String givenDartVmServicePort;
      late MasonGenerator givenDevServerBundleGenerator;
      late Directory givenWorkingDirectory;

      final command = DevCommand(
        generator: (_) async => generator,
        ensureRuntimeCompatibility: (_) {},
        devServerRunnerBuilder: ({
          required logger,
          required port,
          required devServerBundleGenerator,
          required dartVmServicePort,
          required workingDirectory,
          void Function()? onHotReloadEnabled,
        }) {
          givenPort = port;
          givenDartVmServicePort = dartVmServicePort;
          givenDevServerBundleGenerator = devServerBundleGenerator;
          givenWorkingDirectory = workingDirectory;
          return runner;
        },
        logger: logger,
      )
        ..testArgResults = argResults
        ..testCwd = cwd;

      await expectLater(command.run(), completion(ExitCode.success.code));

      verify(() => runner.start()).called(1);

      expect(givenPort, equals('1234'));
      expect(givenDartVmServicePort, equals('5678'));
      expect(givenDevServerBundleGenerator, same(generator));
      expect(givenWorkingDirectory, same(cwd));
    });

    test('results with dev server exit code', () async {
      final command = DevCommand(
        generator: (_) async => generator,
        ensureRuntimeCompatibility: (_) {},
        devServerRunnerBuilder: ({
          required logger,
          required port,
          required devServerBundleGenerator,
          required dartVmServicePort,
          required workingDirectory,
          void Function()? onHotReloadEnabled,
        }) {
          return runner;
        },
        logger: logger,
      )..testArgResults = argResults;

      when(() => runner.start()).thenAnswer((_) => Future.value());
      when(() => runner.exitCode).thenAnswer(
        (_) => Future.value(ExitCode.unavailable),
      );

      await expectLater(command.run(), completion(ExitCode.unavailable.code));
    });

    test('fails if dev server runner fails on start', () async {
      final command = DevCommand(
        generator: (_) async => generator,
        ensureRuntimeCompatibility: (_) {},
        devServerRunnerBuilder: ({
          required logger,
          required port,
          required devServerBundleGenerator,
          required dartVmServicePort,
          required workingDirectory,
          void Function()? onHotReloadEnabled,
        }) {
          return runner;
        },
        logger: logger,
      )..testArgResults = argResults;

      when(() => runner.start()).thenAnswer((_) async {
        throw DartFrogDevServerException('oops');
      });

      await expectLater(command.run(), completion(ExitCode.software.code));
      verify(() => logger.err('oops')).called(1);
    });
  });
}
