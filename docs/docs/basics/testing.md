---
sidebar_position: 5
---

# Testing 🧪

In Dart Frog, we can unit test our route handlers and middleware effectively because they are plain functions.

For example, we can test our route handler above using `package:test`:

```dart
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/index.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('GET /', () {
    test('responds with a 200 and greeting.', () async {
      const greeting = 'Hello World!';
      final context = _MockRequestContext();
      when(() => context.read<String>()).thenReturn(greeting);
      final response = route.onRequest(context);
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body(), completion(equals(greeting)));
    });
  });
}
```

In the above test, we're using `package:mocktail` to create a mock `RequestContext` and stub the return value when calling `context.read<String>()`. Then, all we need to do is call `onRequest` with the mocked context and we can assert that the response is what we expect. In this case, we're checking the statusCode and response body to ensure that the response is a 200 with the provided greeting.
