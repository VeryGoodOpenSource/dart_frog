import 'package:dart_frog_cli/src/daemon/daemon.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockLogger extends Mock implements Logger {}

void main() {
  group('$Daemon', () {
    test('should instantiate', () {
      expect(Daemon(), isNotNull);
    });

    test('placeholder behavior', () async {
      final Logger logger;
      final daemon = Daemon(logger: logger = _MockLogger());
      verify(() => logger.detail('Starting Dart Frog daemon...')).called(1);
      await expectLater(daemon.exitCode, completion(ExitCode.success));
      verify(() => logger.detail('Killing Dart Frog daemon...')).called(1);
    });

    group('kill', () {
      test('exits with given exit code', () async {
        final daemon = Daemon()..kill(ExitCode.unavailable);
        await expectLater(daemon.exitCode, completion(ExitCode.unavailable));
      });
    });
  });
}
