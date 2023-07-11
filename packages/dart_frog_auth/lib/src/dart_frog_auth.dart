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
typedef Applies = Future<bool> Function(RequestContext);

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
/// return a user object from the username and password.
///
/// If the given function returns null for the given username and password,
/// the middleware will return a `401 Unauthorized` response.
///
/// By default, this middleware will apply to all routes. You can change this
/// behavior by providing a function that returns a boolean value based on the
/// [RequestContext]. If the function returns false, the middleware will not
/// apply to the route and the call will have authentication validation.
Middleware basicAuthentication<T extends Object>({
  required Future<T?> Function(String, String) userFromCredentials,
  Applies applies = _defaultApplies,
}) =>
    (handler) => (context) async {
          if (!await applies(context)) {
            return handler(context);
          }

          final authorization = context.request.headers.basic();
          if (authorization != null) {
            final [username, password] =
                String.fromCharCodes(base64Decode(authorization)).split(':');

            final user = await userFromCredentials(username, password);
            if (user != null) {
              return handler(context.provide(() => user));
            }
          }

          return Response(statusCode: HttpStatus.unauthorized);
        };

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
/// return a user object from the received token.
///
/// If the given function returns null for the given username and password,
/// the middleware will return a `401 Unauthorized` response.
///
/// By default, this middleware will apply to all routes. You can change this
/// behavior by providing a function that returns a boolean value based on the
/// [RequestContext]. If the function returns false, the middleware will not
/// apply to the route and the call will have no authentication validation.
Middleware bearerAuthentication<T extends Object>({
  required Future<T?> Function(String) userFromToken,
  Applies applies = _defaultApplies,
}) =>
    (handler) => (context) async {
          if (!await applies(context)) {
            return handler(context);
          }

          final authorization = context.request.headers.bearer();
          if (authorization != null) {
            final user = await userFromToken(authorization);
            if (user != null) {
              return handler(context.provide(() => user));
            }
          }

          return Response(statusCode: HttpStatus.unauthorized);
        };
