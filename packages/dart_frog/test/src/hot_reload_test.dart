import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:test/test.dart';

void main() {
  group('hotReload', () {
    test('completes', () async {
      var invoked = false;
      HttpServer? server;

      Future<HttpServer> initializer() async {
        invoked = true;
        return server = await serve((_) => Response(), 'localhost', 8080);
      }

      expect(() => hotReload(initializer), returnsNormally);
      await Future<void>.delayed(const Duration(seconds: 1));

      expect(invoked, isTrue);
      expect(server, isNotNull);

      await server!.close(force: true);
    });
  });
}
