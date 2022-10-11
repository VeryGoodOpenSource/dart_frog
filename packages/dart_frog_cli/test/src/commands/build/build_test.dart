import 'package:dart_frog_cli/src/commands/commands.dart';
import 'package:dart_frog_cli/src/runtime_compatibility.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockLogger extends Mock implements Logger {}

class _MockMasonGenerator extends Mock implements MasonGenerator {}

class _MockGeneratorHooks extends Mock implements GeneratorHooks {}

class _MockProgress extends Mock implements Progress {}

class _FakeDirectoryGeneratorTarget extends Fake
    implements DirectoryGeneratorTarget {}

void main() {
  group('dart_frog build', () {
    setUpAll(() {
      registerFallbackValue(_FakeDirectoryGeneratorTarget());
    });

    late Logger logger;
    late Progress progress;
    late MasonGenerator generator;
    late BuildCommand command;

    setUp(() {
      logger = _MockLogger();
      progress = _MockProgress();
      when(() => logger.progress(any())).thenReturn(progress);
      generator = _MockMasonGenerator();
      command = BuildCommand(
        logger: logger,
        ensureRuntimeCompatibility: (_) {},
        generator: (_) async => generator,
      );
    });

    test('throws if ensureRuntimeCompatibility fails', () {
      command = BuildCommand(
        logger: logger,
        ensureRuntimeCompatibility: (_) {
          throw const DartFrogCompatibilityException('oops');
        },
      );
      expect(command.run, throwsA(isA<DartFrogCompatibilityException>()));
    });

    test('generates a build successfully.', () async {
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
      when(
        () => generatorHooks.postGen(
          vars: any(named: 'vars'),
          workingDirectory: any(named: 'workingDirectory'),
        ),
      ).thenAnswer((_) async {});
      when(() => generator.hooks).thenReturn(generatorHooks);
      final exitCode = await command.run();
      expect(exitCode, equals(ExitCode.success.code));
    });
  });
}
