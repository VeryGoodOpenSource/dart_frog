import 'dart:async';

import 'package:dart_frog_cli/src/commands/daemon/daemon.dart';
import 'package:dart_frog_cli/src/daemon/daemon.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockDaemon extends Mock implements Daemon {}

void main() {
  group('dart_frog daemon', () {
    test('should instantiate', () {
      expect(DaemonCommand(), isNotNull);
    });

    test(
      'starts a daemon, waits for it to be completed and returns exit code',
      () async {
        final daemon = MockDaemon();
        final completer = Completer<ExitCode>();
        when(() => daemon.exitCode).thenAnswer(
          (_) => completer.future,
        );
        final command = DaemonCommand(daemonBuilder: () => daemon);
        final future = command.run();
        verify(() => daemon.exitCode).called(1);
        completer.complete(ExitCode.success);
        final result = await future;
        expect(result, ExitCode.success.code);
      },
    );
  });
}
