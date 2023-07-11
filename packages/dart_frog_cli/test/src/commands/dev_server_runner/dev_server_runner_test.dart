import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_frog_cli/src/dev_server_runner/dev_server_runner.dart';
import 'package:dart_frog_cli/src/dev_server_runner/restorable_directory_generator_target.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:watcher/watcher.dart';

class _MockDirectoryWatcher extends Mock implements DirectoryWatcher {}

class _MockLogger extends Mock implements Logger {}

class _MockMasonGenerator extends Mock implements MasonGenerator {}

class _MockGeneratorHooks extends Mock implements GeneratorHooks {}

class _MockProcess extends Mock implements Process {}

class _MockProcessSignal extends Mock implements ProcessSignal {}

class _MockProgress extends Mock implements Progress {}

class _MockRestorableDirectoryGeneratorTarget extends Mock
    implements RestorableDirectoryGeneratorTarget {}

class _FakeDirectoryGeneratorTarget extends Fake
    implements DirectoryGeneratorTarget {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeDirectoryGeneratorTarget());
  });

  const port = '8080';
  const dartVmServicePort = '8081';

  const processId = 42;
  final processResult = ProcessResult(processId, 0, '', '');

  late Logger logger;
  late DirectoryWatcher directoryWatcher;
  late MasonGenerator generator;
  late bool isWindows;
  late Progress progress;
  late Process process;
  late ProcessSignal sigint;
  late RestorableDirectoryGeneratorTarget generatorTarget;

  late DevServerRunner devServerRunner;

  setUp(() {
    logger = _MockLogger();
    directoryWatcher = _MockDirectoryWatcher();
    generator = _MockMasonGenerator();
    process = _MockProcess();
    generatorTarget = _MockRestorableDirectoryGeneratorTarget();
    isWindows = false;
    sigint = _MockProcessSignal();
    progress = _MockProgress();

    when(() => logger.progress(any())).thenReturn(progress);

    devServerRunner = DevServerRunner(
      logger: logger,
      port: port,
      devServerBundleGenerator: generator,
      dartVmServicePort: dartVmServicePort,
      workingDirectory: Directory.current,
      // test
      directoryWatcher: (_) => directoryWatcher,
      generatorTarget: (
        _, {
        CreateFile? createFile,
        Logger? logger,
      }) =>
          generatorTarget,
      isWindows: isWindows,
      startProcess: (
        String executable,
        List<String> arguments, {
        bool runInShell = false,
      }) async {
        return process;
      },
      sigint: sigint,
      runProcess: (_, __) async => processResult,
    );
  });

  group('$DevServerRunner', () {
    test('can be instantiated', () {
      expect(
        DevServerRunner(
          logger: Logger(),
          port: '8080',
          devServerBundleGenerator: _MockMasonGenerator(),
          dartVmServicePort: '8081',
          workingDirectory: Directory.current,
        ),
        isNotNull,
      );
    });
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
      (invocation.namedArguments[const Symbol('onVarsChanged')] as void
              Function(Map<String, dynamic> vars))
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

    final exitCode = await devServerRunner.start();
    expect(exitCode, equals(ExitCode.success));
    verify(
      () => generatorHooks.preGen(
        vars: <String, dynamic>{'port': '8080'},
        workingDirectory: any(named: 'workingDirectory'),
        onVarsChanged: any(named: 'onVarsChanged'),
      ),
    ).called(1);
  });

  test('logs process.stdout', () async {
    final generatorHooks = _MockGeneratorHooks();
    when(
      () => generatorHooks.preGen(
        vars: any(named: 'vars'),
        workingDirectory: any(named: 'workingDirectory'),
        onVarsChanged: any(named: 'onVarsChanged'),
      ),
    ).thenAnswer((invocation) async {
      (invocation.namedArguments[const Symbol('onVarsChanged')] as void
              Function(Map<String, dynamic> vars))
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
      (_) => Stream.fromIterable([
        utf8.encode('  Message A  '),
        utf8.encode(''),
        utf8.encode(' Message B'),
        utf8.encode(' '),
        utf8.encode('Message C '),
        utf8.encode('  '),
        utf8.encode('Message D'),
      ]),
    );
    when(() => process.stderr).thenAnswer((_) => const Stream.empty());
    when(
      () => directoryWatcher.events,
    ).thenAnswer((_) => const Stream.empty());

    devServerRunner.start().ignore();

    await Future<void>.delayed(Duration.zero);

    verifyInOrder([
      () => logger.info('Message A'),
      () => logger.info('Message B'),
      () => logger.info('Message C'),
      () => logger.info('Message D'),
    ]);
  });

  test(
    'runs codegen w/debounce '
    'when changes are made to the public/routes directory',
    () async {
      final controller = StreamController<WatchEvent>();
      final generatorHooks = _MockGeneratorHooks();
      when(
        () => generatorHooks.preGen(
          vars: any(named: 'vars'),
          workingDirectory: any(named: 'workingDirectory'),
          onVarsChanged: any(named: 'onVarsChanged'),
        ),
      ).thenAnswer((invocation) async {
        (invocation.namedArguments[const Symbol('onVarsChanged')] as void
                Function(Map<String, dynamic> vars))
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
      when(() => directoryWatcher.events).thenAnswer((_) => controller.stream);

      devServerRunner.start().ignore();

      await Future<void>.delayed(Duration.zero);

      verify(
        () => generator.generate(
          any(),
          vars: any(named: 'vars'),
          fileConflictResolution: FileConflictResolution.overwrite,
        ),
      ).called(1);

      controller
        ..add(
          WatchEvent(
            ChangeType.ADD,
            path.join(Directory.current.path, 'routes', 'users.dart'),
          ),
        )
        ..add(
          WatchEvent(
            ChangeType.REMOVE,
            path.join(Directory.current.path, 'routes', 'user.dart'),
          ),
        );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      verify(
        () => generator.generate(
          any(),
          vars: any(named: 'vars'),
          fileConflictResolution: FileConflictResolution.overwrite,
        ),
      ).called(1);

      controller.add(
        WatchEvent(
          ChangeType.MODIFY,
          path.join(Directory.current.path, 'public', 'hello.txt'),
        ),
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      verify(
        () => generator.generate(
          any(),
          vars: any(named: 'vars'),
          fileConflictResolution: FileConflictResolution.overwrite,
        ),
      ).called(1);

      controller.add(
        WatchEvent(
          ChangeType.MODIFY,
          path.join(Directory.current.path, 'tmp', 'message.txt'),
        ),
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      verifyNever(
        () => generator.generate(
          any(),
          vars: any(named: 'vars'),
          fileConflictResolution: FileConflictResolution.overwrite,
        ),
      );
    },
  );

  test('runs codegen when changes are made to main.dart', () async {
    final controller = StreamController<WatchEvent>();
    final generatorHooks = _MockGeneratorHooks();
    when(
      () => generatorHooks.preGen(
        vars: any(named: 'vars'),
        workingDirectory: any(named: 'workingDirectory'),
        onVarsChanged: any(named: 'onVarsChanged'),
      ),
    ).thenAnswer((invocation) async {
      (invocation.namedArguments[const Symbol('onVarsChanged')] as void
              Function(Map<String, dynamic> vars))
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
    when(() => directoryWatcher.events).thenAnswer((_) => controller.stream);

    devServerRunner.start().ignore();

    await Future<void>.delayed(Duration.zero);

    verify(
      () => generator.generate(
        any(),
        vars: any(named: 'vars'),
        fileConflictResolution: FileConflictResolution.overwrite,
      ),
    ).called(1);

    controller.add(
      WatchEvent(
        ChangeType.ADD,
        path.join(Directory.current.path, 'main.dart'),
      ),
    );

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    verify(
      () => generator.generate(
        any(),
        vars: any(named: 'vars'),
        fileConflictResolution: FileConflictResolution.overwrite,
      ),
    ).called(1);
  });

  test('runs codegen when changes are made to pubspec.yaml', () async {
    final controller = StreamController<WatchEvent>();
    final generatorHooks = _MockGeneratorHooks();
    when(
      () => generatorHooks.preGen(
        vars: any(named: 'vars'),
        workingDirectory: any(named: 'workingDirectory'),
        onVarsChanged: any(named: 'onVarsChanged'),
      ),
    ).thenAnswer((invocation) async {
      (invocation.namedArguments[const Symbol('onVarsChanged')] as void
              Function(Map<String, dynamic> vars))
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
    when(() => directoryWatcher.events).thenAnswer((_) => controller.stream);

    devServerRunner.start().ignore();

    await Future<void>.delayed(Duration.zero);

    verify(
      () => generator.generate(
        any(),
        vars: any(named: 'vars'),
        fileConflictResolution: FileConflictResolution.overwrite,
      ),
    ).called(1);

    controller.add(
      WatchEvent(
        ChangeType.MODIFY,
        path.join(Directory.current.path, 'pubspec.yaml'),
      ),
    );

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    verify(
      () => generator.generate(
        any(),
        vars: any(named: 'vars'),
        fileConflictResolution: FileConflictResolution.overwrite,
      ),
    ).called(1);
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
      (invocation.namedArguments[const Symbol('onVarsChanged')] as void
              Function(Map<String, dynamic> vars))
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
    final exitCode = await devServerRunner.start();
    expect(exitCode, equals(ExitCode.success));
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
      (invocation.namedArguments[const Symbol('onVarsChanged')] as void
              Function(Map<String, dynamic> vars))
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
    when(() => generatorTarget.rollback()).thenAnswer((_) async {});
    when(() => process.stdout).thenAnswer((_) => stdoutController.stream);
    when(() => process.stderr).thenAnswer((_) => stderrController.stream);
    when(() => directoryWatcher.events).thenAnswer(
      (_) => const Stream.empty(),
    );

    devServerRunner.start().ignore();

    stdoutController.add(utf8.encode('[hotreload] hot reload enabled'));
    await untilCalled(() => generatorTarget.cacheLatestSnapshot());

    const error = 'something went wrong';

    stderrController.add(utf8.encode(error));
    await untilCalled(() => generatorTarget.rollback());

    await stderrController.close();
    await stdoutController.close();

    verify(() => generatorTarget.cacheLatestSnapshot()).called(1);
    verify(() => generatorTarget.rollback()).called(1);
    verify(() => logger.err(error)).called(1);
  });

  test('custom port numbers', () async {
    final generatorHooks = _MockGeneratorHooks();
    when(
      () => generatorHooks.preGen(
        vars: any(named: 'vars'),
        workingDirectory: any(named: 'workingDirectory'),
        onVarsChanged: any(named: 'onVarsChanged'),
      ),
    ).thenAnswer((invocation) async {
      (invocation.namedArguments[const Symbol('onVarsChanged')] as void
              Function(Map<String, dynamic> vars))
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
    when(() => directoryWatcher.events).thenAnswer((_) => const Stream.empty());

    late List<String> receivedArgs;

    devServerRunner = DevServerRunner(
      logger: logger,
      port: '4242',
      devServerBundleGenerator: generator,
      dartVmServicePort: '4343',
      workingDirectory: Directory.current,
      // test

      directoryWatcher: (_) => directoryWatcher,
      generatorTarget: (
        _, {
        CreateFile? createFile,
        Logger? logger,
      }) =>
          generatorTarget,
      isWindows: isWindows,
      startProcess: (
        String executable,
        List<String> arguments, {
        bool runInShell = false,
      }) async {
        receivedArgs = arguments;
        return process;
      },
      sigint: sigint,
      runProcess: (_, __) async => processResult,
    );

    final exitCode = await devServerRunner.start();
    expect(exitCode, equals(ExitCode.success));

    expect(
      receivedArgs,
      equals([
        '--enable-vm-service=4343',
        '.dart_frog/server.dart',
      ]),
    );
    verify(
      () => generatorHooks.preGen(
        vars: <String, dynamic>{'port': '4242'},
        workingDirectory: any(named: 'workingDirectory'),
        onVarsChanged: any(named: 'onVarsChanged'),
      ),
    ).called(1);
  });

  test('kills all child processes when sigint received on windows', () async {
    final generatorHooks = _MockGeneratorHooks();
    final processRunCalls = <List<String>>[];

    when(
      () => generatorHooks.preGen(
        vars: any(named: 'vars'),
        workingDirectory: any(named: 'workingDirectory'),
        onVarsChanged: any(named: 'onVarsChanged'),
      ),
    ).thenAnswer((invocation) async {
      (invocation.namedArguments[const Symbol('onVarsChanged')] as void
              Function(Map<String, dynamic> vars))
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
    when(
      () => directoryWatcher.events,
    ).thenAnswer((_) => StreamController<WatchEvent>().stream);
    when(() => sigint.watch()).thenAnswer((_) => Stream.value(sigint));
    devServerRunner = DevServerRunner(
      logger: logger,
      port: port,
      devServerBundleGenerator: generator,
      dartVmServicePort: dartVmServicePort,
      workingDirectory: Directory.current,
      // test

      directoryWatcher: (_) => directoryWatcher,
      exit: (code) => exitCode = code,
      isWindows: true,
      startProcess: (
        String executable,
        List<String> arguments, {
        bool runInShell = false,
      }) async {
        return process;
      },
      sigint: sigint,
      runProcess: (String executable, List<String> arguments) async {
        processRunCalls.add([executable, ...arguments]);
        return processResult;
      },
    );

    devServerRunner.start().ignore();
    await untilCalled(() => process.pid);
    expect(
      processRunCalls,
      equals([
        ['taskkill', '/F', '/T', '/PID', '$processId']
      ]),
    );
    verifyNever(() => process.kill());
  });

  test(
    'kills process if error occurs before hotreload is enabled on windows',
    () async {
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
        (invocation.namedArguments[const Symbol('onVarsChanged')] as void
                Function(Map<String, dynamic> vars))
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
      when(
        () => directoryWatcher.events,
      ).thenAnswer((_) => StreamController<WatchEvent>().stream);
      when(() => sigint.watch()).thenAnswer((_) => const Stream.empty());
      devServerRunner = DevServerRunner(
        logger: logger,
        port: port,
        devServerBundleGenerator: generator,
        dartVmServicePort: dartVmServicePort,
        workingDirectory: Directory.current,
        // test

        directoryWatcher: (_) => directoryWatcher,
        exit: (code) => exitCode = code,
        isWindows: true,
        startProcess: (
          String executable,
          List<String> arguments, {
          bool runInShell = false,
        }) async {
          return process;
        },
        sigint: sigint,
        runProcess: (String executable, List<String> arguments) async {
          processRunCalls.add([executable, ...arguments]);
          return processResult;
        },
      );

      devServerRunner.start().ignore();
      await untilCalled(() => process.pid);
      expect(exitCode, equals(1));
      expect(
        processRunCalls,
        equals([
          ['taskkill', '/F', '/T', '/PID', '$processId']
        ]),
      );
      verifyNever(() => process.kill());
    },
  );

  test(
    'dont kills process if a warning occurs before '
    'hotreload is enabled',
    () async {
      const warningMessage = """
lib/my_model.g.dart:53:20: Warning: Operand of null-aware operation '!' has type 'String' which excludes null.
          ? _value.name!
                   ^
          """;
      final generatorHooks = _MockGeneratorHooks();
      when(
        () => generatorHooks.preGen(
          vars: any(named: 'vars'),
          workingDirectory: any(named: 'workingDirectory'),
          onVarsChanged: any(named: 'onVarsChanged'),
        ),
      ).thenAnswer((invocation) async {
        (invocation.namedArguments[const Symbol('onVarsChanged')] as void
                Function(Map<String, dynamic> vars))
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
        (_) => Stream.value(
          utf8.encode(warningMessage),
        ),
      );
      when(
        () => directoryWatcher.events,
      ).thenAnswer(
        (_) => Stream.value(WatchEvent(ChangeType.MODIFY, 'README.md')),
      );
      devServerRunner = DevServerRunner(
        logger: logger,
        port: port,
        devServerBundleGenerator: generator,
        dartVmServicePort: dartVmServicePort,
        workingDirectory: Directory.current,
        // test

        directoryWatcher: (_) => directoryWatcher,
        startProcess: (
          String executable,
          List<String> arguments, {
          bool runInShell = false,
        }) async {
          return process;
        },
        sigint: sigint,
      );

      final exitCode = await devServerRunner.start();
      expect(exitCode, equals(ExitCode.success));
      verify(
        () => generatorHooks.preGen(
          vars: <String, dynamic>{'port': '8080'},
          workingDirectory: any(named: 'workingDirectory'),
          onVarsChanged: any(named: 'onVarsChanged'),
        ),
      ).called(1);
      verifyNever(() => process.kill());
      verify(() => logger.warn(warningMessage.trim())).called(1);
    },
  );

  test(
    'kills process if error occurs before '
    'hotreload is enabled on non-windows',
    () async {
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
        (invocation.namedArguments[const Symbol('onVarsChanged')] as void
                Function(Map<String, dynamic> vars))
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
      when(() => process.kill()).thenReturn(true);
      when(
        () => directoryWatcher.events,
      ).thenAnswer((_) => StreamController<WatchEvent>().stream);
      when(() => sigint.watch()).thenAnswer((_) => const Stream.empty());
      devServerRunner = DevServerRunner(
        logger: logger,
        port: port,
        devServerBundleGenerator: generator,
        dartVmServicePort: dartVmServicePort,
        workingDirectory: Directory.current,
        // test

        directoryWatcher: (_) => directoryWatcher,
        exit: (code) => exitCode = code,
        startProcess: (
          String executable,
          List<String> arguments, {
          bool runInShell = false,
        }) async {
          return process;
        },
        sigint: sigint,
        runProcess: (String executable, List<String> arguments) async {
          processRunCalls.add([executable, ...arguments]);
          return processResult;
        },
      );

      devServerRunner.start().ignore();
      await untilCalled(() => process.kill());
      expect(exitCode, equals(1));
      expect(processRunCalls, isEmpty);
      verify(() => process.kill()).called(1);
    },
  );

  test(
    'kills process with helpful message when Dart VM is already in use',
    () async {
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
        (invocation.namedArguments[const Symbol('onVarsChanged')] as void
                Function(Map<String, dynamic> vars))
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
      const errorMessage =
          'Could not start the VM service: localhost:8181 is already in use.';
      when(() => process.stderr).thenAnswer(
        (_) => Stream.value(utf8.encode(errorMessage)),
      );
      when(() => process.kill()).thenReturn(true);
      when(
        () => directoryWatcher.events,
      ).thenAnswer((_) => StreamController<WatchEvent>().stream);
      when(() => sigint.watch()).thenAnswer((_) => const Stream.empty());
      devServerRunner = DevServerRunner(
        logger: logger,
        port: port,
        devServerBundleGenerator: generator,
        dartVmServicePort: dartVmServicePort,
        workingDirectory: Directory.current,
        // test

        directoryWatcher: (_) => directoryWatcher,
        exit: (code) => exitCode = code,
        startProcess: (
          String executable,
          List<String> arguments, {
          bool runInShell = false,
        }) async {
          return process;
        },
        sigint: sigint,
        runProcess: (String executable, List<String> arguments) async {
          processRunCalls.add([executable, ...arguments]);
          return processResult;
        },
      );

      devServerRunner.start().ignore();
      await untilCalled(() => process.kill());
      expect(
        exitCode,
        equals(1),
        reason: 'Should exit when VM service is already in use.',
      );
      expect(
        processRunCalls,
        isEmpty,
        reason: 'Should not run the serve process.',
      );
      verify(() => process.kill()).called(1);
      verify(
        () => logger.err(
          '$errorMessage '
          '''Try specifying a different port using the `--dart-vm-service-port` argument when running `dart_frog dev`.''',
        ),
      ).called(1);
    },
  );
}
