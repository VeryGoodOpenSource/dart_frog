import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

final _request = Request('GET', _localhostUri);
final _localhostUri = Uri.parse('http://localhost/');

Future<Response> _makeSimpleRequest(Handler handler) {
  return Future.sync(() => handler(_SimpleRequestContext()));
}

class _MockRequestContext extends Mock implements RequestContext {}

class _SimpleRequestContext extends Fake implements RequestContext {
  @override
  Request get request => _request;
}

void main() {
  group('Cascade', () {
    group('a cascade with several handlers', () {
      late Handler handler;

      setUp(() {
        Response handler1(RequestContext context) {
          if (context.request.headers['one'] == 'false') {
            return Response(statusCode: HttpStatus.notFound, body: 'handler 1');
          } else {
            return Response(body: 'handler 1');
          }
        }

        Response handler2(RequestContext context) {
          if (context.request.headers['two'] == 'false') {
            return Response(statusCode: HttpStatus.notFound, body: 'handler 2');
          } else {
            return Response(body: 'handler 2');
          }
        }

        Response handler3(RequestContext context) {
          if (context.request.headers['three'] == 'false') {
            return Response(statusCode: HttpStatus.notFound, body: 'handler 3');
          } else {
            return Response(body: 'handler 3');
          }
        }

        handler = Cascade().add(handler1).add(handler2).add(handler3).handler;
      });

      test('the first response should be returned if it matches', () async {
        final response = await _makeSimpleRequest(handler);

        expect(response.statusCode, equals(200));
        expect(response.body(), completion(equals('handler 1')));
      });

      test(
          'the second response should be returned if it matches and the first '
          "doesn't", () async {
        final context = _MockRequestContext();
        final request = Request(
          'GET',
          _localhostUri,
          headers: {'one': 'false'},
        );
        when(() => context.request).thenReturn(request);

        final response = await handler(context);

        expect(response.statusCode, equals(200));
        expect(response.body(), completion(equals('handler 2')));
      });

      test(
          'the third response should be returned if it matches and the first '
          "two don't", () async {
        final context = _MockRequestContext();
        final request = Request(
          'GET',
          _localhostUri,
          headers: {'one': 'false', 'two': 'false'},
        );
        when(() => context.request).thenReturn(request);

        final response = await handler(context);

        expect(response.statusCode, equals(200));
        expect(response.body(), completion(equals('handler 3')));
      });

      test('the third response should be returned if no response matches',
          () async {
        final context = _MockRequestContext();
        final request = Request(
          'GET',
          _localhostUri,
          headers: {'one': 'false', 'two': 'false', 'three': 'false'},
        );
        when(() => context.request).thenReturn(request);

        final response = await handler(context);

        expect(response.statusCode, equals(404));
        expect(response.body(), completion(equals('handler 3')));
      });
    });

    test('a 404 response triggers a cascade by default', () async {
      final handler = Cascade()
          .add(
            (_) => Response(statusCode: HttpStatus.notFound, body: 'handler 1'),
          )
          .add((_) => Response(body: 'handler 2'))
          .handler;

      final response = await _makeSimpleRequest(handler);

      expect(response.statusCode, equals(200));
      expect(response.body(), completion(equals('handler 2')));
    });

    test('a 405 response triggers a cascade by default', () async {
      final handler = Cascade()
          .add((_) => Response(statusCode: 405))
          .add((_) => Response(body: 'handler 2'))
          .handler;

      final response = await _makeSimpleRequest(handler);

      expect(response.statusCode, equals(200));
      expect(response.body(), completion(equals('handler 2')));
    });

    test('[statusCodes] controls which statuses cause cascading', () async {
      final handler = Cascade(statusCodes: [302, 403])
          .add((_) => Response(statusCode: HttpStatus.found, body: '/'))
          .add(
            (_) =>
                Response(statusCode: HttpStatus.forbidden, body: 'handler 2'),
          )
          .add(
            (_) => Response(statusCode: HttpStatus.notFound, body: 'handler 3'),
          )
          .add((_) => Response(body: 'handler 4'))
          .handler;

      final response = await _makeSimpleRequest(handler);

      expect(response.statusCode, equals(404));
      expect(response.body(), completion(equals('handler 3')));
    });

    test('[shouldCascade] controls which responses cause cascading', () async {
      bool shouldCascade(Response response) => response.statusCode.isOdd;

      final handler = Cascade(shouldCascade: shouldCascade)
          .add(
            (_) => Response(statusCode: HttpStatus.movedPermanently, body: '/'),
          )
          .add(
            (_) =>
                Response(statusCode: HttpStatus.forbidden, body: 'handler 2'),
          )
          .add(
            (_) => Response(statusCode: HttpStatus.notFound, body: 'handler 3'),
          )
          .add((_) => Response(body: 'handler 4'))
          .handler;

      final response = await _makeSimpleRequest(handler);

      expect(response.statusCode, equals(404));
      expect(response.body(), completion(equals('handler 3')));
    });

    group('errors', () {
      test('getting the handler for an empty cascade fails', () {
        expect(() => Cascade().handler, throwsStateError);
      });

      test(
          'passing [statusCodes] and [shouldCascade] '
          'at the same time fails', () {
        expect(
          () => Cascade(statusCodes: [404, 405], shouldCascade: (_) => false),
          throwsArgumentError,
        );
      });
    });
  });
}
