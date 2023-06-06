[![Dart Frog Logo][logo_white]][dart_frog_link_dark]
[![Dart Frog Logo][logo_black]][dart_frog_link_light]

[![ci][ci_badge]][ci_link]
[![coverage][coverage_badge]][ci_link]
[![pub package][pub_badge]][pub_link]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

Header Authorization support for [Dart Frog][dart_frog_link].

Developed with 💙 by [Very Good Ventures][very_good_ventures_link] 🦄

## About

There are many different approaches when tackling authentication in a backend, `dart_frog_auth`
focus on providing the foundations where more complex authentication methods can be built on top
of.

The authentication methods provided in `dart_frog_auth` are based on `Authorization` specification,
which consist in a framework defined by [`General HTTP`][general_http], here you will find support
for `Basic` and `Bearer` authentications, which are common methods used around the world.

## Basic Authentication

Like its name infers, it is a basic authentication method, that consists on the client sending
the user's credentials in the `Authorization` header. The credentials should be sent concated by a
colon and encoded in a base64 string, the encoded credentials are then set in the header as
follows:

```
Authorization: Basic TOKEN
```

Due to the credentials being sent encoded and not encrypted, this authentication can be considered
to have lessen security levels, specially with used out of a HTTPS/TLS context.

## Bearer Authentication

Similar in its format to the Basic authentication, but with the difference that instead of
sending the users credentials on the header, a token is sent instead.

This token format is up to the authority server to issued it to define, but most of the times
it will an access token with encrypted information that the server can validate.

The header is defined as follows:

```
Authorization: Bearer TOKEN
```

## How to use

Both authentication methods described above can be applied to a dart frog server by adding their
respectives middlewares to the routes that needs to be secured.

Consider the following application:
```
lib/
  |- user_repository.dart
routes/
  |- admin/
  |    |- index.dart
  |- posts/
       |- index.dart
```

Routes under `posts` are public, so they don't require any kind of authentication, while on
`admin`, only authenticated users can access their endpoints. Also worth noting that the
`user_repository.dart` file under the `lib` folder offers methods to find users by different
methods.

### Basic method

To implement authentication via the `Basic` method on `admin` routes, a middleware file should
be created under the admin folder with the following content:

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
        BasicAuth<User>(
          userFromCredentials: userRepository.fetchFromCredentials,
        ).build(),
      );
}
```

`userFromCredentials` parameter must be a method that receives two positional arguments (username
and password) and returns a user if any is found for those credentials or null.

If a user is returned, it will be set in the request context and can be read on request handlers,
for example:

```dart
import 'package:dart_frog/dart_frog.dart';
import 'package:blog/user.dart';

Response onRequest(RequestContext context) {
  final user = context.read<User>();
  return Response.json(body: {'user': user.id});
}
```

In the case of `null` be returned, the middleware will automatically send a `401` in the response.

### Bearer method

To implement authentication via the `Bearer` method on `admin` routes, the same logic used for the
basic method can be applied:

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
        BearerAuth<User>(
          userFromToken: userRepository.fetchFromAccessToken,
        ).build(),
      );
}
```

`userFromToken` parameter must be a method that receives one positional argument (which is the
token sent on the authorization header) and returns a user if any is found for that token.

Again, just like in the basic method, If a user is returned, it will be set in the request
context and can be read on request handlers, for example:

```dart
import 'package:dart_frog/dart_frog.dart';
import 'package:blog/user.dart';

Response onRequest(RequestContext context) {
  final user = context.read<User>();
  return Response.json(body: {'user': user.id});
}
```

In the case of `null` be returned, the middleware will automatically send a `401` in the response.

[ci_badge]: https://github.com/VeryGoodOpenSource/dart_frog/actions/workflows/dart_frog_web_socket.yaml/badge.svg
[ci_link]: https://github.com/VeryGoodOpenSource/dart_frog/actions/workflows/dart_frog_web_socket.yaml
[coverage_badge]: https://raw.githubusercontent.com/VeryGoodOpenSource/dart_frog/main/packages/dart_frog_web_socket/coverage_badge.svg
[dart_frog_link]: https://github.com/verygoodopensource/dart_frog
[dart_frog_link_dark]: https://github.com/verygoodopensource/dart_frog#gh-dark-mode-only
[dart_frog_link_light]: https://github.com/verygoodopensource/dart_frog#gh-light-mode-only
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VeryGoodOpenSource/dart_frog/main/assets/dart_frog_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VeryGoodOpenSource/dart_frog/main/assets/dart_frog_logo_white.png#gh-dark-mode-only
[pub_badge]: https://img.shields.io/pub/v/dart_frog_web_socket.svg
[pub_link]: https://pub.dartlang.org/packages/dart_frog_web_socket
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_ventures_link]: https://verygood.ventures
[general_http]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication#the_general_http_authentication_framework
