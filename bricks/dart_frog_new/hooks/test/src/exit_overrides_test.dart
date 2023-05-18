import 'dart:io';

import 'package:dart_frog_new_hooks/src/exit_overrides.dart';
import 'package:test/test.dart';

void main() {
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
