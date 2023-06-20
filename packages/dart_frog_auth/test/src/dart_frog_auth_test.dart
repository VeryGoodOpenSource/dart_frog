// ignore_for_file: prefer_const_constructors
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

class _User {
  const _User(this.id);
  final String id;
}

void main() {
  group('BasicAuth', () {
    late RequestContext context;
    late Request request;
    _User? user;

    setUp(() {
      context = _MockRequestContext();
      request = _MockRequest();
      when(() => context.provide<_User>(any())).thenReturn(context);
      when(() => request.headers).thenReturn({});
      when(() => context.request).thenReturn(request);
    });

    test('returns 401 when no Authorization header is not present', () async {
      final middleware = basicAuthentication<_User>(
        userFromCredentials: (_, __) async => user,
      );
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
      'returns 401 when Authorization header is present but invalid',
      () async {
        when(() => request.headers).thenReturn({'Authorization': 'not valid'});
        final middleware = basicAuthentication<_User>(
          userFromCredentials: (_, __) async => user,
        );
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
      'returns 401 when Authorization header is present and valid but no '
      'user is returned',
      () async {
        when(() => request.headers).thenReturn({
          'Authorization': 'Basic dXNlcjpwYXNz',
        });
        final middleware = basicAuthentication<_User>(
          userFromCredentials: (_, __) async => null,
        );
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
        user = _User('');
        when(() => request.headers).thenReturn({
          'Authorization': 'Basic dXNlcjpwYXNz',
        });
        final middleware = basicAuthentication<_User>(
          userFromCredentials: (_, __) async => user,
        );
        expect(
          await middleware((_) async => Response())(context),
          isA<Response>().having(
            (r) => r.statusCode,
            'statusCode',
            HttpStatus.ok,
          ),
        );
        final captured =
            verify(() => context.provide<_User>(captureAny())).captured.single;
        expect(
          (captured as _User Function()).call(),
          equals(user),
        );
      },
    );
  });

  group('BearerAuth', () {
    late RequestContext context;
    late Request request;
    _User? user;

    setUp(() {
      context = _MockRequestContext();
      request = _MockRequest();
      when(() => context.provide<_User>(any())).thenReturn(context);
      when(() => request.headers).thenReturn({});
      when(() => context.request).thenReturn(request);
    });

    test('returns 401 when no Authorization header is not present', () async {
      final middleware = bearerTokenAuthentication<_User>(
        userFromToken: (_) async => user,
      );
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
      'returns 401 when Authorization header is present but invalid',
      () async {
        when(() => request.headers).thenReturn({'Authorization': 'not valid'});
        final middleware = bearerTokenAuthentication<_User>(
          userFromToken: (_) async => user,
        );
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
      'returns 401 when Authorization header is present and valid but no '
      'user is returned',
      () async {
        when(() => request.headers).thenReturn({
          'Authorization': 'Bearer 1234',
        });
        final middleware = bearerTokenAuthentication<_User>(
          userFromToken: (_) async => null,
        );
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
        user = _User('');
        when(() => request.headers).thenReturn({
          'Authorization': 'Bearer 1234',
        });
        final middleware = bearerTokenAuthentication<_User>(
          userFromToken: (_) async => user,
        );
        expect(
          await middleware((_) async => Response())(context),
          isA<Response>().having(
            (r) => r.statusCode,
            'statusCode',
            HttpStatus.ok,
          ),
        );
        final captured =
            verify(() => context.provide<_User>(captureAny())).captured.single;
        expect(
          (captured as _User Function()).call(),
          equals(user),
        );
      },
    );
  });
}
