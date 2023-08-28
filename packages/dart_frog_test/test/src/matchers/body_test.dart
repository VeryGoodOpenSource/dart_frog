import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_test/dart_frog_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockResponse extends Mock implements Response {}

void main() {
  group('body matchers', () {
    test('can expect a json body', () {
      final response = _MockResponse();
      when(response.json).thenAnswer((_) async => {'hello': 'world'});

      expectJsonBody(response, {'hello': 'world'});
    });

    test('can expect a text body', () {
      final response = _MockResponse();
      when(response.body).thenAnswer((_) async => 'hello world');

      expectBody(response, 'hello world');
    });
  });
}
