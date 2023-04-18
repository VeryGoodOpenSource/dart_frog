import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/_middleware.dart';

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('middleware', () {
    test('provides incremented count', () async {
      final handler = middleware((context) => Response());
      final request = Request.get(Uri.parse('http://localhost/'));
      final context = _MockRequestContext();

      when(() => context.request).thenReturn(request);
      when(() => context.provide<int>(any())).thenReturn(context);

      await handler(context);

      final create = verify(() => context.provide<int>(captureAny()))
          .captured
          .single as int Function();

      expect(create(), equals(1));
      expect(create(), equals(2));
      expect(create(), equals(3));
    });
  });
}
