import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/count/index.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('GET /', () {
    test('responds with a 200 and count.', () async {
      const count = 42;
      final context = _MockRequestContext();
      when(() => context.read<int>()).thenReturn(count);
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
