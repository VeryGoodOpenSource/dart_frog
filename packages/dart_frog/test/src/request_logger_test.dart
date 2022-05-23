// ignore_for_file: avoid_positional_boolean_parameters

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockRequestContext extends Mock implements RequestContext {}

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
      Response handler(RequestContext context) => Response.ok('');
      final _handler = const Pipeline()
          .addMiddleware(requestLogger(logger: logger))
          .addHandler(handler);
      final request = Request('GET', Uri.parse('http://127.0.0.1/'));
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(request);
      await _handler(context);

      expect(gotLog, isTrue);
    });
  });
}
