import 'dart:io';

import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../post_gen.dart';

class _FakeHookContext extends Fake implements HookContext {
  _FakeHookContext({Logger? logger}) : _logger = logger ?? _MockLogger();

  final Logger _logger;

  var _vars = <String, dynamic>{};

  @override
  Map<String, dynamic> get vars => _vars;

  @override
  set vars(Map<String, dynamic> value) => _vars = value;

  @override
  Logger get logger => _logger;
}

class _MockLogger extends Mock implements Logger {}

class _MockProgress extends Mock implements Progress {}

class _MockProcessResult extends Mock implements ProcessResult {}

void main() {
  group('postGen', () {
    late HookContext context;
    late Logger logger;

    setUp(() {
      logger = _MockLogger();
      context = _FakeHookContext(logger: logger);

      when(() => logger.progress(any())).thenReturn(_MockProgress());
    });

    test('run completes', () {
      expect(
        ExitOverrides.runZoned(
          () => run(_FakeHookContext(logger: logger)),
          exit: (_) {},
        ),
        completes,
      );
    });

    test('runs dart pub get and outputs next steps', () async {
      final exitCalls = <int>[];
      final result = _MockProcessResult();
      when(() => result.exitCode).thenReturn(ExitCode.success.code);
      await postGen(
        context,
        runProcess: (
          executable,
          args, {
          String? workingDirectory,
          bool? runInShell,
        }) async {
          return result;
        },
        exit: exitCalls.add,
      );
      expect(exitCalls, isEmpty);
      verify(() => logger.success('Created a production build!')).called(1);
      verify(
        () => logger.info('Start the production server by running:'),
      ).called(1);
      verify(
        () => logger.info('${lightCyan.wrap('dart build/bin/server.dart')}'),
      ).called(1);
      verifyNever(() => logger.err(any()));
    });

    group('dartPubGet', () {
      test('completes when process succeeds', () async {
        final exitCalls = <int>[];
        final result = _MockProcessResult();
        when(() => result.exitCode).thenReturn(ExitCode.success.code);
        await dartPubGet(
          context,
          workingDirectory: '.',
          runProcess: (
            executable,
            args, {
            String? workingDirectory,
            bool? runInShell,
          }) async {
            expect(executable, equals('dart'));
            expect(args, equals(['pub', 'get']));
            expect(workingDirectory, equals('.'));
            expect(runInShell, isTrue);
            return result;
          },
          exit: exitCalls.add,
        );
        expect(exitCalls, isEmpty);
        verifyNever(() => logger.err(any()));
      });

      test('exits when process fails', () async {
        const error = 'oops something went wrong';
        final exitCalls = <int>[];
        final result = _MockProcessResult();
        final code = ExitCode.software.code;
        when(() => result.exitCode).thenReturn(code);
        when(() => result.stderr).thenReturn(error);
        await dartPubGet(
          context,
          workingDirectory: '.',
          runProcess: (
            executable,
            args, {
            String? workingDirectory,
            bool? runInShell,
          }) async {
            return result;
          },
          exit: exitCalls.add,
        );
        expect(exitCalls, equals([code]));
        verify(() => logger.err(error)).called(1);
      });

      test('exits when ProcessException occurs', () async {
        const error = 'oops something went wrong';
        final exitCalls = <int>[];
        final result = _MockProcessResult();
        final code = ExitCode.software.code;
        when(() => result.exitCode).thenReturn(code);
        when(() => result.stderr).thenReturn(error);
        await dartPubGet(
          context,
          workingDirectory: '.',
          runProcess: (
            executable,
            args, {
            String? workingDirectory,
            bool? runInShell,
          }) async {
            throw ProcessException('dart', ['pub', 'get'], error, code);
          },
          exit: exitCalls.add,
        );
        expect(exitCalls, equals([code]));
        verify(() => logger.err(error)).called(1);
      });
    });
  });

  group('ExitOverrides', () {
    group('runZoned', () {
      test('uses default exit when not specified', () {
        ExitOverrides.runZoned(() {
          final overrides = ExitOverrides.current;
          expect(overrides!.exit, equals(exit));
        });
      });

      test('uses custom exit when specified', () {
        ExitOverrides.runZoned(
          () {
            final overrides = ExitOverrides.current;
            expect(overrides!.exit, isNot(equals(exit)));
          },
          exit: (_) {},
        );
      });
    });
  });
}
