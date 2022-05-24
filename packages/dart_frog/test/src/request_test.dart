import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:test/test.dart';

void main() {
  group('Request', () {
    final localhost = Uri.parse('http://localhost/');

    test('has correct url', () {
      final request = Request('GET', localhost);
      expect(request.url, equals(Uri()));
    });

    test('has correct uri', () {
      final request = Request('GET', localhost);
      expect(request.uri, equals(localhost));
    });

    test('has correct body (string)', () {
      const body = '__test_body__';
      final request = Request('GET', localhost, body: body);
      expect(request.body(), completion(equals(body)));
    });

    test('has correct body (json)', () {
      const body = {'test': 'body'};
      final request = Request('GET', localhost, body: json.encode(body));
      expect(request.json(), completion(equals(body)));
    });

    test('has correct body (byte array)', () {
      const body = 'hello';
      final request = Request('GET', localhost, body: utf8.encode(body));
      expect(request.bytes(), emits(utf8.encode(body)));
    });

    test('has correct headers', () {
      const headers = <String, String>{'foo': 'bar'};
      final request = Request('GET', localhost, headers: headers);
      expect(request.headers['foo'], equals(headers['foo']));
    });

    group('copyWith', () {
      test('returns a copy with overridden properties', () {
        const headers = <String, String>{'foo': 'bar'};
        const path = '';
        const body = 'test-body';
        final original = Request('GET', localhost);
        final copy = original.copyWith(
          headers: headers,
          path: path,
          body: body,
        );
        expect(copy.method, equals(HttpMethod.get));
        expect(copy.headers['foo'], equals(headers['foo']));
        expect(copy.url, equals(Uri()));
        expect(copy.body(), completion(equals(body)));
      });
    });

    group('delete', () {
      test('has correct method', () {
        final request = Request.delete(localhost);
        expect(request.method, equals(HttpMethod.delete));
      });
    });

    group('get', () {
      test('has correct method', () {
        final request = Request.get(localhost);
        expect(request.method, equals(HttpMethod.get));
      });
    });

    group('patch', () {
      test('has correct method', () {
        final request = Request.patch(localhost);
        expect(request.method, equals(HttpMethod.patch));
      });
    });

    group('post', () {
      test('has correct method', () {
        final request = Request.post(localhost);
        expect(request.method, equals(HttpMethod.post));
      });
    });

    group('put', () {
      test('has correct method', () {
        final request = Request.put(localhost);
        expect(request.method, equals(HttpMethod.put));
      });
    });
  });
}
