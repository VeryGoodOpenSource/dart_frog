import 'dart:developer';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/count/index.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockCounter extends Mock implements Counter {}

void main() {
  group('GET /', () {
    test('responds with a 200 and count.', () async {
      const count = 42;
      final counter = _MockCounter();
      when(() => counter.value).thenReturn(count.toDouble());
      final context = _MockRequestContext();
      when(() => context.read<Counter>()).thenReturn(counter);
      final response = route.onRequest(context);
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(
        response.body(),
        completion(
          equals('You have requested this route $count time(s).'),
        ),
      );
    });
  });
}
