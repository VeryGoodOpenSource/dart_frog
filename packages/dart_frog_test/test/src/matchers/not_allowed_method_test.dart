import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_test/dart_frog_test.dart';
import 'package:test/test.dart';

void main() {
  group('not allowed methods matchers', () {
    test('can expect not allowed methods', () async {
      await expectNotAllowedMethods(
        (context) {
          return Response(
            statusCode: context.request.method == HttpMethod.get
                ? HttpStatus.ok
                : HttpStatus.methodNotAllowed,
          );
        },
        contextBuilder: (method) {
          final context = DartFrogTestContext(
            path: '/test',
            method: method,
          );
          return context;
        },
        allowedMethods: [HttpMethod.get],
      );
    });
  });
}
