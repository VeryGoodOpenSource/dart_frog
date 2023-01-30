import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:web_socket_counter/counter/counter.dart';

import '../../routes/_middleware.dart';

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('middleware', () {
    test('provides a CounterCubit instance.', () async {
      CounterCubit? cubit;
      final handler = middleware(
        (context) {
          cubit = context.read<CounterCubit>();
          return Response();
        },
      );
      final request = Request.get(Uri.parse('http://localhost/'));
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(request);

      await handler(context);
      expect(cubit, isNotNull);
    });
  });
}
