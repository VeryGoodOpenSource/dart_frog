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

class _MockStdin extends Mock implements Stdin {}

void main() {
  group('dart_frog dev', () {
    late ArgResults argResults;
    late MasonGenerator generator;
    late DevServerRunner runner;
    late Logger logger;
    late Stdin stdin;

    setUp(() {
      argResults = _MockArgResults();
      generator = _MockMasonGenerator();
      runner = _MockDevServerRunner();
      logger = _MockLogger();
      stdin = _MockStdin();

      when<dynamic>(() => argResults['host']).thenReturn('127.0.0.1');
      when<dynamic>(() => argResults['port']).thenReturn('8080');
      when<dynamic>(() => argResults['dart-vm-service-port'])
          .thenReturn('8181');
      when(() => stdin.hasTerminal).thenReturn(false);
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
          required host,
          required port,
          required devServerBundleGenerator,
          required dartVmServicePort,
          required workingDirectory,
          void Function()? onHotReloadEnabled,
        }) {
          return runner;
        },
        logger: logger,
      )
        ..testArgResults = argResults
        ..testStdin = stdin;

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

      when(() => argResults['host']).thenReturn('0.0.0.0');
      when(() => argResults['port']).thenReturn('1234');
      when(() => argResults['dart-vm-service-port']).thenReturn('5678');

      final cwd = Directory.systemTemp;

      late String givenHost;
      late String givenPort;
      late String givenDartVmServicePort;
      late MasonGenerator givenDevServerBundleGenerator;
      late Directory givenWorkingDirectory;
      late void Function()? givenOnHotReloadEnabled;

      final command = DevCommand(
        generator: (_) async => generator,
        ensureRuntimeCompatibility: (_) {},
        devServerRunnerBuilder: ({
          required logger,
          required host,
          required port,
          required devServerBundleGenerator,
          required dartVmServicePort,
          required workingDirectory,
          void Function()? onHotReloadEnabled,
        }) {
          givenHost = host;
          givenPort = port;
          givenDartVmServicePort = dartVmServicePort;
          givenDevServerBundleGenerator = devServerBundleGenerator;
          givenWorkingDirectory = workingDirectory;
          givenOnHotReloadEnabled = onHotReloadEnabled;
          return runner;
        },
        logger: logger,
      )
        ..testStdin = stdin
        ..testArgResults = argResults
        ..testCwd = cwd;

      await expectLater(command.run(), completion(ExitCode.success.code));

      verify(() => runner.start()).called(1);

      expect(givenHost, equals('0.0.0.0'));
      expect(givenPort, equals('1234'));
      expect(givenDartVmServicePort, equals('5678'));
      expect(givenDevServerBundleGenerator, same(generator));
      expect(givenWorkingDirectory, same(cwd));
      expect(givenOnHotReloadEnabled, isNotNull);
    });

    test('results with dev server exit code', () async {
      final command = DevCommand(
        generator: (_) async => generator,
        ensureRuntimeCompatibility: (_) {},
        devServerRunnerBuilder: ({
          required logger,
          required host,
          required port,
          required devServerBundleGenerator,
          required dartVmServicePort,
          required workingDirectory,
          void Function()? onHotReloadEnabled,
        }) {
          return runner;
        },
        logger: logger,
      )
        ..testArgResults = argResults
        ..testStdin = stdin;

      when(() => runner.start()).thenAnswer((_) => Future.value());
      when(() => runner.exitCode).thenAnswer(
        (_) => Future.value(ExitCode.success),
      );

      when(() => runner.start()).thenAnswer((_) => Future.value());
      when(() => runner.exitCode).thenAnswer((_) async => ExitCode.unavailable);

      await expectLater(command.run(), completion(ExitCode.unavailable.code));
    });

    test('fails if dev server runner fails on start', () async {
      final command = DevCommand(
        generator: (_) async => generator,
        ensureRuntimeCompatibility: (_) {},
        devServerRunnerBuilder: ({
          required logger,
          required host,
          required port,
          required devServerBundleGenerator,
          required dartVmServicePort,
          required workingDirectory,
          void Function()? onHotReloadEnabled,
        }) {
          return runner;
        },
        logger: logger,
      )
        ..testArgResults = argResults
        ..testStdin = stdin;

      when(() => runner.start()).thenAnswer((_) async {
        throw DartFrogDevServerException('oops');
      });

      await expectLater(command.run(), completion(ExitCode.software.code));
      verify(() => logger.err('oops')).called(1);
    });

    group('listening to stdin', () {
      late Stdin stdin;
      late StreamController<List<int>> stdinController;
      late DevCommand command;
      late void Function() givenOnHotReloadEnabled;
      late Completer<ExitCode> exitCodeCompleter;

      setUp(() {
        stdin = _MockStdin();
        exitCodeCompleter = Completer<ExitCode>();

        when(() => stdin.hasTerminal).thenReturn(true);

        stdinController = StreamController<List<int>>();
        addTearDown(() {
          stdinController.close();
        });

        when(
          () => stdin.listen(
            any(),
            onError: any(named: 'onError'),
            onDone: any(named: 'onDone'),
            cancelOnError: any(named: 'cancelOnError'),
          ),
        ).thenAnswer(
          (invocation) => stdinController.stream.listen(
            invocation.positionalArguments.first as void Function(List<int>),
            onError: invocation.namedArguments[#onError] as Function?,
            onDone: invocation.namedArguments[#onDone] as void Function()?,
            cancelOnError: invocation.namedArguments[#cancelOnError] as bool?,
          ),
        );

        when(() => runner.start()).thenAnswer((_) => Future.value());

        when(() => runner.reload()).thenAnswer((_) => Future.value());
        when(() => runner.exitCode).thenAnswer(
          (_) => exitCodeCompleter.future,
        );

        command = DevCommand(
          generator: (_) async => generator,
          ensureRuntimeCompatibility: (_) {},
          devServerRunnerBuilder: ({
            required logger,
            required host,
            required port,
            required devServerBundleGenerator,
            required dartVmServicePort,
            required workingDirectory,
            void Function()? onHotReloadEnabled,
          }) {
            givenOnHotReloadEnabled = onHotReloadEnabled!;
            return runner;
          },
          logger: logger,
        )
          ..testArgResults = argResults
          ..testStdin = stdin;
      });

      test('listens for R on hot reload enabled', () async {
        command.run().ignore();
        await Future<void>.delayed(Duration.zero);

        verifyNever(
          () => stdin.listen(
            any(),
            onError: any(named: 'onError'),
            onDone: any(named: 'onDone'),
            cancelOnError: true,
          ),
        );
        verifyNever(() => logger.info('Press R to reload'));

        givenOnHotReloadEnabled();

        verifyNever(() => runner.reload());
        verify(
          () => stdin.listen(
            any(),
            onError: any(named: 'onError'),
            onDone: any(named: 'onDone'),
            cancelOnError: true,
          ),
        ).called(1);
        verify(() => logger.info('Press R to reload')).called(1);

        verify(() => stdin.echoMode = false).called(1);
        verify(() => stdin.lineMode = false).called(1);

        stdinController.add([42]);
        await Future<void>.delayed(Duration.zero);

        verifyNever(() => runner.reload());

        stdinController.add([82, 42]);
        await Future<void>.delayed(Duration.zero);

        verifyNever(() => runner.reload());

        stdinController.add([82]);
        await Future<void>.delayed(Duration.zero);

        verify(() => runner.reload()).called(1);

        exitCodeCompleter.complete(ExitCode.success);
      });

      test('cancels subscription when dev server stops', () async {
        command.run().ignore();
        await Future<void>.delayed(Duration.zero);

        givenOnHotReloadEnabled();
        await Future<void>.delayed(Duration.zero);

        exitCodeCompleter.complete(ExitCode.success);
        await Future<void>.delayed(Duration.zero);

        expect(stdinController.hasListener, isFalse);
        verify(() => stdin.echoMode = true).called(1);
        verify(() => stdin.lineMode = true).called(1);
      });

      test('cancels subscription when dev server throws', () async {
        final startComplter = Completer<void>();
        when(() => runner.start()).thenAnswer((_) async {
          await startComplter.future;
        });

        command.run().ignore();
        await Future<void>.delayed(Duration.zero);

        givenOnHotReloadEnabled();
        await Future<void>.delayed(Duration.zero);

        expect(stdinController.hasListener, isTrue);
        verify(() => stdin.echoMode = false).called(1);
        verify(() => stdin.lineMode = false).called(1);

        startComplter.completeError(Exception('oops'));
        await Future<void>.delayed(Duration.zero);

        expect(stdinController.hasListener, isFalse);
        verify(() => stdin.echoMode = true).called(1);
        verify(() => stdin.lineMode = true).called(1);
      });

      test('cancels subscription when stdin emits error', () async {
        command.run().ignore();
        await Future<void>.delayed(Duration.zero);

        givenOnHotReloadEnabled();
        await Future<void>.delayed(Duration.zero);

        stdinController.addError(Exception('oops'));
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(stdinController.hasListener, isFalse);
        verify(() => stdin.echoMode = true).called(1);
        verify(() => stdin.lineMode = true).called(1);

        exitCodeCompleter.complete(ExitCode.success);
      });
    });
  });
}
