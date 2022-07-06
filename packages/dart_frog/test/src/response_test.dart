import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:test/test.dart';

void main() {
  group('Response', () {
    group('statusCode', () {
      test('defaults to 200.', () {
        final response = Response();
        expect(response.statusCode, equals(HttpStatus.ok));
      });

      test('can be overridden.', () {
        const expected = HttpStatus.notFound;
        final response = Response(statusCode: expected);
        expect(response.statusCode, equals(expected));
      });
    });

    test('has correct body', () {
      const body = 'test-body';
      final response = Response(body: body);
      expect(response.body(), completion(equals(body)));
    });

    test('has correct headers', () {
      const headers = <String, String>{'foo': 'bar'};
      final response = Response(headers: headers);
      expect(response.headers['foo'], equals(headers['foo']));
    });

    group('copyWith', () {
      test('returns a copy with overridden properties', () {
        const headers = <String, String>{'foo': 'bar'};
        const body = 'test-body';
        final original = Response();
        final copy = original.copyWith(
          headers: headers,
          body: body,
        );
        expect(copy.headers['foo'], equals(headers['foo']));
        expect(copy.body(), completion(equals(body)));
      });
    });

    group('bytes', () {
      test('has correct body', () {
        final bytes = utf8.encode('hello');
        final response = Response.bytes(body: bytes);
        expect(response.bytes(), emits(equals(bytes)));
      });
    });

    group('json', () {
      test('has correct body (map)', () {
        final body = <String, dynamic>{'foo': 'bar'};
        final response = Response.json(body: body);
        expect(response.json(), completion(equals(body)));
      });

      test('has correct body (list)', () {
        final body = <String>['foo', 'bar'];
        final response = Response.json(body: body);
        expect(response.json(), completion(equals(body)));
      });

      test('has correct body (string)', () {
        const body = 'foo';
        final response = Response.json(body: body);
        expect(response.json(), completion(equals(body)));
      });

      test('has correct body (number)', () {
        const body = 42.0;
        final response = Response.json(body: body);
        expect(response.json(), completion(equals(body)));
      });

      test('has correct body (bool)', () {
        const body = false;
        final response = Response.json(body: body);
        expect(response.json(), completion(equals(body)));
      });
    });
  });
}
