import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:web_socket_counter/counter/counter.dart';

import '../../routes/_middleware.dart';

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('middleware', () {
    test('provides a CounterCubit instance.', () async {
      final handler = middleware((_) => Response());
      final request = Request.get(Uri.parse('http://localhost/'));
      final context = _MockRequestContext();

      when(() => context.request).thenReturn(request);
      when(() => context.provide<CounterCubit>(any())).thenReturn(context);

      await handler(context);

      final create = verify(() => context.provide<CounterCubit>(captureAny()))
          .captured
          .single as CounterCubit Function();
      expect(create(), isA<CounterCubit>());
    });
  });
}
