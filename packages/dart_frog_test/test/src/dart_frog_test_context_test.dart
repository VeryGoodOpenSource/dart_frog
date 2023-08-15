// ignore_for_file: prefer_const_constructors
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_test/dart_frog_test.dart';
import 'package:test/test.dart';

void main() {
  group('DartFrogTestContext', () {
    test('can be instantiated', () {
      expect(DartFrogTestContext(path: '/'), isNotNull);
    });

    test('creates the correct RequestContext', () {
      final testContext = DartFrogTestContext(
        path: '/',
        method: HttpMethod.post,
        headers: {'content-type': 'application/json'},
        body: 'hello world',
      );

      final context = testContext.context;
      expect(context.request.uri, equals(Uri.parse('https://test.com/')));
      expect(context.request.method, equals(HttpMethod.post));
      expect(
        context.request.headers,
        equals(
          {
            'content-type': 'application/json',
            'content-length': '11',
          },
        ),
      );
      expect(context.request.body(), completion(equals('hello world')));
    });

    test('can mock a dependency', () {
      final testContext = DartFrogTestContext(path: '/')
        ..provide<String>('hello');

      final context = testContext.context;
      expect(context.read<String>(), equals('hello'));
    });
  });
}
