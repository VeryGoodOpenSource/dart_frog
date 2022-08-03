import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/_middleware.dart';

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('middleware', () {
    test('provides incremented count', () async {
      int? count;
      final handler = middleware(
        (context) {
          count = context.read<int>();
          return Response(body: '');
        },
      );
      final request = Request.get(Uri.parse('http://localhost/'));
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(request);

      await handler(context);
      expect(count, equals(1));

      await handler(context);
      expect(count, equals(2));

      await handler(context);
      expect(count, equals(3));
    });
  });
}
