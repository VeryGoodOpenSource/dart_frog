import 'package:dart_frog_cli/src/command_runner.dart';
import 'package:dart_frog_cli/src/commands/uninstall/uninstall.dart';
import 'package:mason/mason.dart' hide packageVersion;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

void main() {
  group('dart_frog uninstall', () {
    late Logger logger;
    late UninstallCommand command;

    setUp(() {
      logger = MockLogger();
      command = UninstallCommand(logger: logger);
    });

    test('prints a link to the documentation section', () async {
      final result = await command.run();
      const message =
          'For instructions on how to uninstall $packageName completely, '
          'check out:\nhttps://dartfrog.vgv.dev/docs/overview#uninstalling-';

      expect(result, equals(ExitCode.success.code));
      verify(() => logger.info(message)).called(1);
    });
  });
}
