import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

extension on Map<String, String> {
  String? authorization(String type) {
    final value = this['Authorization']?.split(' ');

    if (value != null && value.length == 2 && value.first == type) {
      return value.last;
    }

    return null;
  }

  String? bearer() => authorization('Bearer');
  String? basic() => authorization('Basic');
}

/// Function definition for the predicate function used by Dart Frog Auth
/// middleware to determine if the request should be authenticated or not.
typedef Applies = Future<bool> Function(RequestContext context);

Future<bool> _defaultApplies(RequestContext context) async => true;

/// Authentication that uses the `Authorization` header with the `Basic` scheme.
///
/// `Basic` scheme expects the header to be in the format:
/// ```
/// Authorization: Basic <token>
/// ```
///
/// Token should be a base64 encoded string of the format:
/// ```
/// <username>:<password>
/// ```
///
/// In order to use this middleware, you must provide a function that will
/// return a user object from the username, password and request context.
///
/// If the given function returns null for the given username and password,
/// the middleware will return a `401 Unauthorized` response.
///
/// By default, this middleware will apply to all routes. You can change this
/// behavior by providing a function that returns a boolean value based on the
/// [RequestContext]. If the function returns false, the middleware will not
/// apply to the route and the call will have authentication validation.
Middleware basicAuthentication<T extends Object>({
  @Deprecated(
    'Deprecated in favor of authenticator. '
    'This will be removed in future versions',
  )
  Future<T?> Function(
    String username,
    String password,
  )? userFromCredentials,
  Future<T?> Function(
    RequestContext context,
    String username,
    String password,
  )? authenticator,
  Applies applies = _defaultApplies,
}) {
  assert(
    userFromCredentials != null || authenticator != null,
    'You must provide either a userFromCredentials or a '
    'authenticator function',
  );
  return (handler) => (context) async {
        if (!await applies(context)) {
          return handler(context);
        }

        Future<T?> call(String username, String password) async {
          if (userFromCredentials != null) {
            return userFromCredentials(username, password);
          } else {
            return authenticator!(context, username, password);
          }
        }

        final authorization = context.request.headers.basic();
        if (authorization != null) {
          final [username, password] =
              String.fromCharCodes(base64Decode(authorization)).split(':');

          final user = await call(username, password);
          if (user != null) {
            return handler(context.provide(() => user));
          }
        }

        return Response(statusCode: HttpStatus.unauthorized);
      };
}

/// Authentication that uses the `Authorization` header with the `Bearer`
/// scheme.
///
/// `Bearer` scheme expects the header to be in the format:
/// ```
/// Authorization: Bearer <token>
/// ```
///
/// The token format is up to the user. Usually it will be an encrypted token.
///
/// In order to use this middleware, you must provide a function that will
/// return a user object from the received token and request context.
///
/// If the given function returns null for the given username and password,
/// the middleware will return a `401 Unauthorized` response.
///
/// By default, this middleware will apply to all routes. You can change this
/// behavior by providing a function that returns a boolean value based on the
/// [RequestContext]. If the function returns false, the middleware will not
/// apply to the route and the call will have no authentication validation.
Middleware bearerAuthentication<T extends Object>({
  @Deprecated(
    'Deprecated in favor of authenticator. '
    'This will be removed in future versions',
  )
  Future<T?> Function(String token)? userFromToken,
  Future<T?> Function(RequestContext context, String token)? authenticator,
  Applies applies = _defaultApplies,
}) {
  assert(
    userFromToken != null || authenticator != null,
    'You must provide either a userFromToken or a '
    'authenticator function',
  );

  return (handler) => (context) async {
        if (!await applies(context)) {
          return handler(context);
        }

        Future<T?> call(String token) async {
          if (userFromToken != null) {
            return userFromToken(token);
          } else {
            return authenticator!(context, token);
          }
        }

        final authorization = context.request.headers.bearer();
        if (authorization != null) {
          final user = await call(authorization);
          if (user != null) {
            return handler(context.provide(() => user));
          }
        }

        return Response(statusCode: HttpStatus.unauthorized);
      };
}
