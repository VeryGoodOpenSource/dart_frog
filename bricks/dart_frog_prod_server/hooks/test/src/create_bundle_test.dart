import 'dart:io';

import 'package:dart_frog_prod_server_hooks/dart_frog_prod_server_hooks.dart';
import 'package:mason/mason.dart' hide createBundle;
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

class _MockLogger extends Mock implements Logger {}

class _MockProgress extends Mock implements Progress {}

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

void main() {
  group('createBundle', () {
    late HookContext context;
    late Logger logger;

    setUp(() {
      logger = _MockLogger();
      context = _FakeHookContext(logger: logger);

      when(() => logger.progress(any())).thenReturn(_MockProgress());
    });

    test('exit(1) if bundling throws', () async {
      final exitCalls = <int>[];
      await createBundle(
        context: context,
        projectDirectory: Directory('/invalid/dir'),
        buildDirectory: Directory('/invalid/dir/build'),
        exit: exitCalls.add,
      );
      expect(exitCalls, equals([1]));
      verify(() => logger.err(any())).called(1);
    });

    test('does not throw when bundling succeeds', () async {
      final exitCalls = <int>[];
      final projectDirectory = Directory.systemTemp.createTempSync();
      final dotDartFrogDir =
          Directory(path.join(projectDirectory.path, '.dart_frog'))
            ..createSync();
      final buildDirectory =
          Directory(path.join(projectDirectory.path, 'build'))..createSync();
      final oldBuildArtifact =
          File(path.join(buildDirectory.path, 'artifact.txt'))..createSync();

      await createBundle(
        context: context,
        projectDirectory: projectDirectory,
        buildDirectory: buildDirectory,
        exit: exitCalls.add,
      );

      expect(dotDartFrogDir.existsSync(), isFalse);
      expect(buildDirectory.existsSync(), isTrue);
      expect(oldBuildArtifact.existsSync(), isFalse);
      expect(exitCalls, isEmpty);
      verifyNever(() => logger.err(any()));
    });
  });
}
