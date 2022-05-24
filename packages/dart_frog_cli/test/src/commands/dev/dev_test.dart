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

class _FakeDirectoryGeneratorTarget extends Fake
    implements DirectoryGeneratorTarget {}

void main() {
  group('dart_frog dev', () {
    setUpAll(() {
      registerFallbackValue(_FakeDirectoryGeneratorTarget());
    });

    late DirectoryWatcher directoryWatcher;
    late Logger logger;
    late Process process;
    late MasonGenerator generator;
    late DevCommand command;

    setUp(() {
      directoryWatcher = _MockDirectoryWatcher();
      logger = _MockLogger();
      when(() => logger.progress(any())).thenReturn(([_]) {});
      process = _MockProcess();
      generator = _MockMasonGenerator();
      command = DevCommand(
        logger: logger,
        directoryWatcher: (_) => directoryWatcher,
        generator: (_) async => generator,
        startProcess: (
          String executable,
          List<String> arguments, {
          bool runInShell = false,
        }) async {
          return process;
        },
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
  });
}
