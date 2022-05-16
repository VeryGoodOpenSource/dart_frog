// ignore_for_file: avoid_positional_boolean_parameters

import 'package:dart_frog/dart_frog.dart';
import 'package:test/test.dart';

void main() {
  group('requestLogger', () {
    var gotLog = false;

    void logger(String msg, bool isError) {
      expect(gotLog, isFalse);
      gotLog = true;
      expect(isError, isFalse);
      expect(msg, contains('GET'));
      expect(msg, contains('[200]'));
    }

    test('proxies to logRequests', () async {
      Response handler(Request request) => Response.ok('');
      final _handler = const Pipeline()
          .addMiddleware(requestLogger(logger: logger))
          .addHandler(handler);

      await _handler(Request('GET', Uri.parse('http://127.0.0.1/')));

      expect(gotLog, isTrue);
    });
  });
}
