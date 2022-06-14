import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_frog_cli/src/commands/commands.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:watcher/watcher.dart';

class _MockArgResults extends Mock implements ArgResults {}

class _MockDirectoryWatcher extends Mock implements DirectoryWatcher {}

class _MockLogger extends Mock implements Logger {}

class _MockMasonGenerator extends Mock implements MasonGenerator {}

class _MockGeneratorHooks extends Mock implements GeneratorHooks {}

class _MockProcess extends Mock implements Process {}

class _MockProcessResult extends Mock implements ProcessResult {}

class _MockProcessSignal extends Mock implements ProcessSignal {}

class _MockProgress extends Mock implements Progress {}

class _MockRestorableDirectoryGeneratorTarget extends Mock
    implements RestorableDirectoryGeneratorTarget {}

class _FakeDirectoryGeneratorTarget extends Fake
    implements DirectoryGeneratorTarget {}

class _FakeGeneratedFile extends Fake implements GeneratedFile {}

void main() {
  group('dart_frog dev', () {
    setUpAll(() {
      registerFallbackValue(_FakeDirectoryGeneratorTarget());
    });

    late ArgResults argResults;
    late DirectoryWatcher directoryWatcher;
    late MasonGenerator generator;
    late bool isWindows;
    late Progress progress;
    late Logger logger;
    late Process process;
    late ProcessResult processResult;
    late ProcessSignal sigint;
    late RestorableDirectoryGeneratorTarget generatorTarget;
    late DevCommand command;

    setUp(() {
      argResults = _MockArgResults();
      when<dynamic>(() => argResults['port']).thenReturn('8080');
      directoryWatcher = _MockDirectoryWatcher();
      generator = _MockMasonGenerator();
      isWindows = false;
      logger = _MockLogger();
      progress = _MockProgress();
      when(() => logger.progress(any())).thenReturn(progress);
      process = _MockProcess();
      processResult = _MockProcessResult();
      sigint = _MockProcessSignal();
      generatorTarget = _MockRestorableDirectoryGeneratorTarget();
      command = DevCommand(
        logger: logger,
        directoryWatcher: (_) => directoryWatcher,
        generator: (_) async => generator,
        generatorTarget: generatorTarget,
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
      )..testArgResults = argResults;
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
      verify(
        () => generatorHooks.preGen(
          vars: <String, dynamic>{'port': '8080'},
          workingDirectory: any(named: 'workingDirectory'),
          onVarsChanged: any(named: 'onVarsChanged'),
        ),
      ).called(2);
    });

    test('caches snapshot when hotreload runs successfully', () async {
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
      when(() => process.stdout).thenAnswer(
        (_) => Stream.value(utf8.encode('[hotreload] hot reload enabled.')),
      );
      when(() => process.stderr).thenAnswer((_) => const Stream.empty());
      when(() => directoryWatcher.events).thenAnswer(
        (_) => const Stream.empty(),
      );
      final exitCode = await command.run();
      expect(exitCode, equals(ExitCode.success.code));
      verify(() => generatorTarget.cacheLatestSnapshot()).called(1);
    });

    test('restores previous snapshot when hotreload fails.', () async {
      final generatorHooks = _MockGeneratorHooks();
      final stdoutController = StreamController<List<int>>();
      final stderrController = StreamController<List<int>>();
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
      when(() => generatorTarget.restore()).thenAnswer((_) async {});
      when(() => process.stdout).thenAnswer((_) => stdoutController.stream);
      when(() => process.stderr).thenAnswer((_) => stderrController.stream);
      when(() => directoryWatcher.events).thenAnswer(
        (_) => const Stream.empty(),
      );

      command.run().ignore();

      stdoutController.add(utf8.encode('[hotreload] hot reload enabled'));
      await untilCalled(() => generatorTarget.cacheLatestSnapshot());

      const error = 'something went wrong';

      stderrController.add(utf8.encode(error));
      await untilCalled(() => generatorTarget.restore());

      await stderrController.close();
      await stdoutController.close();

      verify(() => generatorTarget.cacheLatestSnapshot()).called(1);
      verify(() => generatorTarget.restore()).called(1);
      verify(() => logger.err(error)).called(1);
    });

    test('port can be specified using --port', () async {
      when<dynamic>(() => argResults['port']).thenReturn('4242');
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
      when(() => directoryWatcher.events)
          .thenAnswer((_) => const Stream.empty());
      final exitCode = await command.run();
      expect(exitCode, equals(ExitCode.success.code));
      verify(
        () => generatorHooks.preGen(
          vars: <String, dynamic>{'port': '4242'},
          workingDirectory: any(named: 'workingDirectory'),
          onVarsChanged: any(named: 'onVarsChanged'),
        ),
      ).called(1);
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
      when(() => process.kill()).thenReturn(true);
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
      )..testArgResults = argResults;
      command.run().ignore();
      await untilCalled(() => process.pid);
      expect(exitCode, equals(ExitCode.success.code));
      expect(
        processRunCalls,
        equals([
          ['taskkill', '/F', '/T', '/PID', '$processId']
        ]),
      );
      verify(() => process.kill()).called(1);
    });

    test('kills process if error occurs before hotreload is enabled', () async {
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
      when(() => process.stderr).thenAnswer(
        (_) => Stream.value(utf8.encode('oops')),
      );
      when(() => process.pid).thenReturn(processId);
      when(() => process.kill()).thenReturn(true);
      when(() => processResult.exitCode).thenReturn(ExitCode.success.code);
      when(
        () => directoryWatcher.events,
      ).thenAnswer((_) => StreamController<WatchEvent>().stream);
      when(() => sigint.watch()).thenAnswer((_) => const Stream.empty());
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
      )..testArgResults = argResults;
      command.run().ignore();
      await untilCalled(() => process.pid);
      expect(exitCode, equals(1));
      expect(
        processRunCalls,
        equals([
          ['taskkill', '/F', '/T', '/PID', '$processId']
        ]),
      );
      verify(() => process.kill()).called(1);
    });
  });

  group('CachedFile', () {
    test('can be instantiated', () {
      const path = './path';
      final contents = <int>[];
      final instance = CachedFile(path: path, contents: contents);
      expect(instance.path, equals(path));
      expect(instance.contents, equals(contents));
    });
  });

  group('RestorableDirectoryGeneratorTarget', () {
    late RestorableDirectoryGeneratorTarget generatorTarget;
    late Directory directory;

    setUpAll(() {
      directory = Directory.systemTemp.createTempSync();
    });

    test('caches and restores snapshots when available', () async {
      const path = './path';
      final contents = utf8.encode('contents');
      final createdFiles = <CachedFile>[];

      generatorTarget = RestorableDirectoryGeneratorTarget(
        directory,
        createFile: (path, contents, {logger, overwriteRule}) async {
          createdFiles.add(CachedFile(path: path, contents: contents));
          return _FakeGeneratedFile();
        },
      );

      await generatorTarget.createFile(path, contents);

      expect(createdFiles.length, equals(1));

      createdFiles.clear();

      generatorTarget.cacheLatestSnapshot();

      const otherPath = './other/path';
      await generatorTarget.createFile(otherPath, contents);

      expect(createdFiles.length, equals(1));
      expect(createdFiles.first.path, equals(otherPath));
      expect(createdFiles.first.contents, equals(contents));

      createdFiles.clear();

      await generatorTarget.restore();

      expect(createdFiles.length, equals(1));
      expect(createdFiles.first.path, equals(path));
      expect(createdFiles.first.contents, equals(contents));
    });

    test('restore does nothing when snapshot not available', () async {
      const path = './path';
      final contents = utf8.encode('contents');
      final createdFiles = <CachedFile>[];

      generatorTarget = RestorableDirectoryGeneratorTarget(
        directory,
        createFile: (path, contents, {logger, overwriteRule}) async {
          createdFiles.add(CachedFile(path: path, contents: contents));
          return _FakeGeneratedFile();
        },
      );

      await generatorTarget.createFile(path, contents);

      expect(createdFiles.length, equals(1));

      createdFiles.clear();

      const otherPath = './other/path';
      await generatorTarget.createFile(otherPath, contents);

      expect(createdFiles.length, equals(1));
      expect(createdFiles.first.path, equals(otherPath));
      expect(createdFiles.first.contents, equals(contents));

      createdFiles.clear();

      await generatorTarget.restore();

      expect(createdFiles, isEmpty);
    });
  });
}
