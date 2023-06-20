# Example

Use `basicAuthentication` to add basic authentication to your routes:

```dart
// routes/admin/_middleware.dart
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:blog/user.dart';

Handler middleware(Handler handler) {
  final userRepository = ...;
  return handler
      .use(requestLogger())
      .use(
        basicAuthentication<User>(
          userFromCredentials: userRepository.fetchFromCredentials,
        ),
      );
}
```

User `bearerTokenAuthentication` to add bearer token authentication to your routes:

```dart
// routes/admin/_middleware.dart
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:blog/user.dart';

Handler middleware(Handler handler) {
  final userRepository = ...;
  return handler
      .use(requestLogger())
      .use(
        bearerTokenAuthentication<User>(
          userFromToken: userRepository.fetchFromAccessToken,
        ),
      );
}
```
