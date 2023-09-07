import 'package:dart_frog_test/dart_frog_test.dart';
import 'package:test/test.dart';

import '../../routes/index.dart' as route;

void main() {
  test(
    'responds with a 200 and "Welcome to Dart Frog!".',
    () async {
      final testContext = TestRequestContext(path: '/');
      final response = route.onRequest(testContext.context);
      expect(response, isOk);
      expectBody(response, 'Welcome to Dart Frog!');
    },
  );
}
