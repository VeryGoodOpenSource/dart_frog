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

/// {@template basic_auth}
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
/// {@endtemplate}
/// Builds the middleware to be used on the dart frog server.
Middleware basicAuthentication<T extends Object>({
  required Future<T?> Function(String, String) userFromCredentials,
}) =>
    (handler) => (context) async {
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

/// {@template basic_auth}
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
/// {@endtemplate}
/// Builds the middleware to be used on the dart frog server.
Middleware bearerTokenAuthentication<T extends Object>({
  required Future<T?> Function(String) userFromToken,
}) =>
    (handler) => (context) async {
          final authorization = context.request.headers.bearer();
          if (authorization != null) {
            final user = await userFromToken(authorization);
            if (user != null) {
              return handler(context.provide(() => user));
            }
          }

          return Response(statusCode: HttpStatus.unauthorized);
        };
