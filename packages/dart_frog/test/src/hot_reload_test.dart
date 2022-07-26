import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:test/test.dart';

void main() {
  group('hotReload', () {
    test('completes', () async {
      final completer = Completer<void>();
      var invoked = false;
      HttpServer? server;

      Future<HttpServer> initializer() async {
        invoked = true;
        server = await serve((_) => Response(), 'localhost', 8080);
        completer.complete();
        return server!;
      }

      expect(() => hotReload(initializer), returnsNormally);

      await completer.future;

      expect(invoked, isTrue);
      expect(server, isNotNull);

      await server!.close(force: true);
    });
  });
}
