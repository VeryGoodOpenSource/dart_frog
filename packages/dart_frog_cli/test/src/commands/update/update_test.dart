import 'dart:io';

import 'package:dart_frog_cli/src/command_runner.dart';
import 'package:dart_frog_cli/src/commands/update/update.dart';
import 'package:dart_frog_cli/src/version.dart';
import 'package:mason/mason.dart' hide packageVersion;
import 'package:mocktail/mocktail.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

class MockPubUpdater extends Mock implements PubUpdater {}

class MockProcessResult extends Mock implements ProcessResult {}

class MockProgress extends Mock implements Progress {}

void main() {
  const latestVersion = '0.0.0';

  group('dart_frog update', () {
    late Logger logger;
    late PubUpdater pubUpdater;
    late UpdateCommand command;
    late ProcessResult processResult;

    setUp(() {
      logger = MockLogger();
      pubUpdater = MockPubUpdater();
      processResult = MockProcessResult();

      when(() => logger.progress(any())).thenReturn(MockProgress());
      when(
        () => pubUpdater.getLatestVersion(any()),
      ).thenAnswer((_) async => packageVersion);
      when(
        () => pubUpdater.update(
          packageName: packageName,
          versionConstraint: any(named: 'versionConstraint'),
        ),
      ).thenAnswer((_) => Future.value(processResult));

      command = UpdateCommand(logger: logger, pubUpdater: pubUpdater);
    });

    test('handles pub latest version query errors', () async {
      when(
        () => pubUpdater.getLatestVersion(any()),
      ).thenThrow(Exception('oops'));
      final result = await command.run();
      expect(result, equals(ExitCode.software.code));
      verify(() => logger.progress('Checking for updates')).called(1);
      verify(() => logger.err('Exception: oops'));
      verifyNever(
        () => pubUpdater.update(
          packageName: any(named: 'packageName'),
          versionConstraint: any(named: 'versionConstraint'),
        ),
      );
    });

    test('handles pub update errors', () async {
      when(
        () => pubUpdater.getLatestVersion(any()),
      ).thenAnswer((_) async => latestVersion);
      when(
        () => pubUpdater.update(
          packageName: any(named: 'packageName'),
          versionConstraint: any(named: 'versionConstraint'),
        ),
      ).thenThrow(Exception('oops'));
      final result = await command.run();
      expect(result, equals(ExitCode.software.code));
      verify(() => logger.progress('Checking for updates')).called(1);
      verify(() => logger.err('Exception: oops'));
      verify(
        () => pubUpdater.update(
          packageName: any(named: 'packageName'),
          versionConstraint: any(named: 'versionConstraint'),
        ),
      ).called(1);
    });

    test('handles pub update process errors', () async {
      const error = 'Oh no! Installing this is not possible right now!';
      when(() => processResult.exitCode).thenReturn(1);
      when<dynamic>(() => processResult.stderr).thenReturn(error);
      when(
        () => pubUpdater.getLatestVersion(any()),
      ).thenAnswer((_) async => latestVersion);
      when(
        () => pubUpdater.update(
          packageName: any(named: 'packageName'),
          versionConstraint: any(named: 'versionConstraint'),
        ),
      ).thenAnswer((_) => Future.value(processResult));

      final result = await command.run();
      expect(result, equals(ExitCode.software.code));
      verify(() => logger.progress('Checking for updates')).called(1);
      verify(() => logger.err('Error updating Dart Frog CLI: $error'));
      verify(
        () => pubUpdater.update(
          packageName: any(named: 'packageName'),
          versionConstraint: any(named: 'versionConstraint'),
        ),
      ).called(1);
    });

    test('updates when newer version exists', () async {
      when(
        () => pubUpdater.getLatestVersion(any()),
      ).thenAnswer((_) async => latestVersion);
      when(
        () => pubUpdater.update(
          packageName: any(named: 'packageName'),
          versionConstraint: any(named: 'versionConstraint'),
        ),
      ).thenAnswer((_) => Future.value(processResult));
      when(() => processResult.exitCode).thenReturn(0);
      when(() => logger.progress(any())).thenReturn(MockProgress());
      final result = await command.run();
      expect(result, equals(ExitCode.success.code));
      verify(() => logger.progress('Checking for updates')).called(1);
      verify(() => logger.progress('Updating to $latestVersion')).called(1);
      verify(
        () => pubUpdater.update(
          packageName: packageName,
          versionConstraint: latestVersion,
        ),
      ).called(1);
    });

    test('does not update when already on latest version', () async {
      when(
        () => pubUpdater.getLatestVersion(any()),
      ).thenAnswer((_) async => packageVersion);
      when(() => logger.progress(any())).thenReturn(MockProgress());
      final result = await command.run();
      expect(result, equals(ExitCode.success.code));
      verify(
        () => logger.info('$packageName is already at the latest version.'),
      ).called(1);
      verifyNever(() => logger.progress('Updating to $latestVersion'));
      verifyNever(
        () => pubUpdater.update(
          packageName: any(named: 'packageName'),
          versionConstraint: any(named: 'versionConstraint'),
        ),
      );
    });
  });
}
