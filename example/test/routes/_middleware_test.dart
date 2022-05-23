import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/_middleware.dart';

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('middleware', () {
    test('provides greeting (String)', () async {
      String? value;
      final handler = middleware(
        (context) {
          value = context.read<String>();
          return Response(body: '');
        },
      );
      final request = Request('GET', Uri.parse('http://127.0.0.1/'));
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(request);
      await handler(context);
      expect(value, isNotNull);
    });
  });
}
