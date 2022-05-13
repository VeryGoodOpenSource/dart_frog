import 'package:dart_frog/dart_frog.dart';
import 'package:test/test.dart';

import '../../routes/_middleware.dart';

void main() {
  group('middleware', () {
    test('provides greeting (String)', () async {
      String? value;
      final handler = middleware(
        (request) {
          value = read<String>(request);
          return Response.ok('');
        },
      );
      final request = Request('GET', Uri.parse('http://127.0.0.1/'));
      await handler(request);
      expect(value, isNotNull);
    });
  });
}
