import 'dart:async';
import 'dart:io';

import 'package:dart_frog_cli/src/commands/commands.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:watcher/watcher.dart';

class _MockDirectoryWatcher extends Mock implements DirectoryWatcher {}

class _MockLogger extends Mock implements Logger {}

class _MockMasonGenerator extends Mock implements MasonGenerator {}

class _MockGeneratorHooks extends Mock implements GeneratorHooks {}

class _MockProcess extends Mock implements Process {}

class _MockProcessResult extends Mock implements ProcessResult {}

class _MockProcessSignal extends Mock implements ProcessSignal {}

class _MockProgress extends Mock implements Progress {}

class _FakeDirectoryGeneratorTarget extends Fake
    implements DirectoryGeneratorTarget {}

void main() {
  group('dart_frog dev', () {
    setUpAll(() {
      registerFallbackValue(_FakeDirectoryGeneratorTarget());
    });

    late DirectoryWatcher directoryWatcher;
    late bool isWindows;
    late Progress progress;
    late Logger logger;
    late Process process;
    late ProcessResult processResult;
    late ProcessSignal sigint;
    late MasonGenerator generator;
    late DevCommand command;

    setUp(() {
      directoryWatcher = _MockDirectoryWatcher();
      isWindows = false;
      logger = _MockLogger();
      progress = _MockProgress();
      when(() => logger.progress(any())).thenReturn(progress);
      process = _MockProcess();
      processResult = _MockProcessResult();
      sigint = _MockProcessSignal();
      generator = _MockMasonGenerator();
      command = DevCommand(
        logger: logger,
        directoryWatcher: (_) => directoryWatcher,
        generator: (_) async => generator,
        isWindows: isWindows,
        runProcess: (String executable, List<String> arguments) async {
          return processResult;
        },
        startProcess: (
          String executable,
          List<String> arguments, {
          bool runInShell = false,
        }) async {
          return process;
        },
        sigint: sigint,
      );
    });

    test('runs a dev server successfully.', () async {
      final generatorHooks = _MockGeneratorHooks();
      when(
        () => generatorHooks.preGen(
          vars: any(named: 'vars'),
          workingDirectory: any(named: 'workingDirectory'),
          onVarsChanged: any(named: 'onVarsChanged'),
        ),
      ).thenAnswer((invocation) async {
        (invocation.namedArguments[const Symbol('onVarsChanged')] as Function(
          Map<String, dynamic> vars,
        ))
            .call(<String, dynamic>{});
      });
      when(
        () => generator.generate(
          any(),
          vars: any(named: 'vars'),
          fileConflictResolution: FileConflictResolution.overwrite,
        ),
      ).thenAnswer((_) async => []);
      when(() => generator.hooks).thenReturn(generatorHooks);
      when(() => process.stdout).thenAnswer((_) => const Stream.empty());
      when(() => process.stderr).thenAnswer((_) => const Stream.empty());
      when(
        () => directoryWatcher.events,
      ).thenAnswer(
        (_) => Stream.value(WatchEvent(ChangeType.MODIFY, 'README.md')),
      );
      final exitCode = await command.run();
      expect(exitCode, equals(ExitCode.success.code));
    });

    test('kills all child processes when sigint received on windows', () async {
      const processId = 42;
      final generatorHooks = _MockGeneratorHooks();
      final processRunCalls = <List<String>>[];
      int? exitCode;
      when(
        () => generatorHooks.preGen(
          vars: any(named: 'vars'),
          workingDirectory: any(named: 'workingDirectory'),
          onVarsChanged: any(named: 'onVarsChanged'),
        ),
      ).thenAnswer((invocation) async {
        (invocation.namedArguments[const Symbol('onVarsChanged')] as Function(
          Map<String, dynamic> vars,
        ))
            .call(<String, dynamic>{});
      });
      when(
        () => generator.generate(
          any(),
          vars: any(named: 'vars'),
          fileConflictResolution: FileConflictResolution.overwrite,
        ),
      ).thenAnswer((_) async => []);
      when(() => generator.hooks).thenReturn(generatorHooks);
      when(() => process.stdout).thenAnswer((_) => const Stream.empty());
      when(() => process.stderr).thenAnswer((_) => const Stream.empty());
      when(() => process.pid).thenReturn(processId);
      when(() => processResult.exitCode).thenReturn(ExitCode.success.code);
      when(
        () => directoryWatcher.events,
      ).thenAnswer((_) => StreamController<WatchEvent>().stream);
      when(() => sigint.watch()).thenAnswer((_) => Stream.value(sigint));
      command = DevCommand(
        logger: logger,
        directoryWatcher: (_) => directoryWatcher,
        generator: (_) async => generator,
        exit: (code) => exitCode = code,
        isWindows: true,
        runProcess: (String executable, List<String> arguments) async {
          processRunCalls.add([executable, ...arguments]);
          return processResult;
        },
        startProcess: (
          String executable,
          List<String> arguments, {
          bool runInShell = false,
        }) async {
          return process;
        },
        sigint: sigint,
      );
      command.run().ignore();
      await untilCalled(() => process.pid);
      expect(exitCode, equals(ExitCode.success.code));
      expect(
        processRunCalls,
        equals([
          ['taskkill', '/F', '/T', '/PID', '$processId']
        ]),
      );
    });
  });
}
