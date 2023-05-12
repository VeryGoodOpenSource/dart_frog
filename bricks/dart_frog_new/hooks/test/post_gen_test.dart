import 'dart:io' as io;

import 'package:dart_frog_new_hooks/post_gen.dart';
import 'package:dart_frog_new_hooks/src/exit_overrides.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

class _MockLogger extends Mock implements Logger {}

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
  group('postGen', () {
    late HookContext context;
    late Logger logger;

    setUp(() {
      logger = _MockLogger();
      context = _FakeHookContext(logger: logger);
    });

    test('postGen completes', () {
      context.vars['dir_path'] = 'routes/new_route';
      context.vars['filename'] = 'index.dart';
      expect(
        ExitOverrides.runZoned(
          () async => postGen(context),
          exit: (_) {},
        ),
        completes,
      );
    });

    test('exit(1) if dir_path is not defined', () {
      final exitCalls = <int>[];
      postGen(context, exit: exitCalls.add);
      expect(exitCalls, equals([1]));
    });

    test('moves file to supposed directory', () {
      final directory = io.Directory.systemTemp.createTempSync(
        'dart_frog_new_hooks_test',
      );
      addTearDown(() {
        directory.deleteSync(recursive: true);
      });
      final filePath = path.join(directory.path, 'index.dart');
      io.File(filePath)
        ..createSync(recursive: true)
        ..writeAsStringSync('content');

      context.vars['dir_path'] = 'routes/new_route';
      context.vars['filename'] = 'index.dart';

      postGen(context, directory: directory);

      expect(
        io.File(path.join(directory.path, 'routes/new_route/index.dart'))
            .readAsStringSync(),
        'content',
      );
    });
  });
}
