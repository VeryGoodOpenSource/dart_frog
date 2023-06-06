// ignore_for_file: prefer_const_constructors
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

class User {
  const User(this.id);
  final String id;
}

void main() {
  group('BasicAuth', () {
    late BasicAuth<User> basicAuth;
    late RequestContext context;
    late Request request;
    User? user;

    setUp(() {
      basicAuth = BasicAuth<User>(userFromCredentials: (_, __) async => user);
      context = _MockRequestContext();
      request = _MockRequest();
      when(() => context.provide<User>(any())).thenReturn(context);
      when(() => request.headers).thenReturn({});
      when(() => context.request).thenReturn(request);
    });

    test('can be instantiated', () {
      expect(
        BasicAuth<User>(userFromCredentials: (_, __) async => null),
        isNotNull,
      );
    });

    test('returns 401 when no Authorization header is not present', () async {
      final middleware = basicAuth.build();
      expect(
        await middleware((_) async => Response())(context),
        isA<Response>().having(
          (r) => r.statusCode,
          'statusCode',
          HttpStatus.unauthorized,
        ),
      );
    });

    test(
      'returns 401 when no Authorization header is present but invalid',
      () async {
        when(() => request.headers).thenReturn({'Authorization': 'not valid'});
        final middleware = basicAuth.build();
        expect(
          await middleware((_) async => Response())(context),
          isA<Response>().having(
            (r) => r.statusCode,
            'statusCode',
            HttpStatus.unauthorized,
          ),
        );
      },
    );

    test(
      'returns 401 when no Authorization header is present and valid but no '
      'user is returned',
      () async {
        when(() => request.headers).thenReturn({
          'Authorization': 'Basic dXNlcjpwYXNz',
        });
        final middleware = basicAuth.build();
        expect(
          await middleware((_) async => Response())(context),
          isA<Response>().having(
            (r) => r.statusCode,
            'statusCode',
            HttpStatus.unauthorized,
          ),
        );
      },
    );

    test(
      'sets the user when everything is valid',
      () async {
        user = User('');
        when(() => request.headers).thenReturn({
          'Authorization': 'Basic dXNlcjpwYXNz',
        });
        final middleware = basicAuth.build();
        expect(
          await middleware((_) async => Response())(context),
          isA<Response>().having(
            (r) => r.statusCode,
            'statusCode',
            HttpStatus.ok,
          ),
        );
        final captured =
            verify(() => context.provide<User>(captureAny())).captured.single;
        expect(
          (captured as User Function()).call(),
          equals(user),
        );
      },
    );
  });

  group('BearerAuth', () {
    late BearerAuth<User> bearerAuth;
    late RequestContext context;
    late Request request;
    User? user;

    setUp(() {
      bearerAuth = BearerAuth<User>(userFromToken: (_) async => user);
      context = _MockRequestContext();
      request = _MockRequest();
      when(() => context.provide<User>(any())).thenReturn(context);
      when(() => request.headers).thenReturn({});
      when(() => context.request).thenReturn(request);
    });

    test('can be instantiated', () {
      expect(
        BasicAuth<User>(userFromCredentials: (_, __) async => null),
        isNotNull,
      );
    });

    test('returns 401 when no Authorization header is not present', () async {
      final middleware = bearerAuth.build();
      expect(
        await middleware((_) async => Response())(context),
        isA<Response>().having(
          (r) => r.statusCode,
          'statusCode',
          HttpStatus.unauthorized,
        ),
      );
    });

    test(
      'returns 401 when no Authorization header is present but invalid',
      () async {
        when(() => request.headers).thenReturn({'Authorization': 'not valid'});
        final middleware = bearerAuth.build();
        expect(
          await middleware((_) async => Response())(context),
          isA<Response>().having(
            (r) => r.statusCode,
            'statusCode',
            HttpStatus.unauthorized,
          ),
        );
      },
    );

    test(
      'returns 401 when no Authorization header is present and valid but no '
      'user is returned',
      () async {
        when(() => request.headers).thenReturn({
          'Authorization': 'Bearer 1234',
        });
        final middleware = bearerAuth.build();
        expect(
          await middleware((_) async => Response())(context),
          isA<Response>().having(
            (r) => r.statusCode,
            'statusCode',
            HttpStatus.unauthorized,
          ),
        );
      },
    );

    test(
      'sets the user when everything is valid',
      () async {
        user = User('');
        when(() => request.headers).thenReturn({
          'Authorization': 'Bearer 1234',
        });
        final middleware = bearerAuth.build();
        expect(
          await middleware((_) async => Response())(context),
          isA<Response>().having(
            (r) => r.statusCode,
            'statusCode',
            HttpStatus.ok,
          ),
        );
        final captured =
            verify(() => context.provide<User>(captureAny())).captured.single;
        expect(
          (captured as User Function()).call(),
          equals(user),
        );
      },
    );
  });
}
