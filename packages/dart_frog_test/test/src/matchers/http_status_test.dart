import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_test/dart_frog_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockResponse extends Mock implements Response {}

class _MockDescription extends Mock implements Description {}

void main() {
  group('http status matchers', () {
    test('isOk', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(200);

      expect(response, isOk);
    });

    test('isCreated', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(201);

      expect(response, isCreated);
    });

    test('isAccepted', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(202);

      expect(response, isAccepted);
    });

    test('isNoContent', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(204);

      expect(response, isNoContent);
    });

    test('isMovedPermanently', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(301);

      expect(response, isMovedPermanently);
    });

    test('isFound', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(302);

      expect(response, isFound);
    });

    test('isSeeOther', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(303);

      expect(response, isSeeOther);
    });

    test('isNotModified', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(304);

      expect(response, isNotModified);
    });

    test('isBadRequest', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(400);

      expect(response, isBadRequest);
    });

    test('isUnauthorized', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(401);

      expect(response, isUnauthorized);
    });

    test('isForbidden', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(403);

      expect(response, isForbidden);
    });

    test('isNotFound', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(404);

      expect(response, isNotFound);
    });

    test('isMethodNotAllowed', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(405);

      expect(response, isMethodNotAllowed);
    });

    test('isNotAcceptable', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(406);

      expect(response, isNotAcceptable);
    });

    test('isConflict', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(409);

      expect(response, isConflict);
    });

    test('isUnsupportedMediaType', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(415);

      expect(response, isUnsupportedMediaType);
    });

    test('isInternalServerError', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(500);

      expect(response, isInternalServerError);
    });

    test('isNotImplemented', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(501);

      expect(response, isNotImplemented);
    });

    test('isBadGateway', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(502);

      expect(response, isBadGateway);
    });

    test('isServiceUnavailable', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(503);

      expect(response, isServiceUnavailable);
    });

    test('isGatewayTimeout', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(504);

      expect(response, isGatewayTimeout);
    });

    test('isRequestTimeout', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(408);

      expect(response, isRequestTimeout);
    });

    test('isTooManyRequests', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(429);

      expect(response, isTooManyRequests);
    });

    test('isPreconditionFailed', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(412);

      expect(response, isPreconditionFailed);
    });

    test('isRequestEntityTooLarge', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(413);

      expect(response, isRequestEntityTooLarge);
    });

    test('isRequestedRangeNotSatisfiable', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(416);

      expect(response, isRequestedRangeNotSatisfiable);
    });

    test('isExpectationFailed', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(417);

      expect(response, isExpectationFailed);
    });

    test('isPreconditionRequired', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(428);

      expect(response, isPreconditionRequired);
    });

    test('isFailedDependency', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(424);

      expect(response, isFailedDependency);
    });

    test('isUpgradeRequired', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(426);

      expect(response, isUpgradeRequired);
    });

    test('isRequestHeaderFieldsTooLarge', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(431);

      expect(response, isRequestHeaderFieldsTooLarge);
    });

    test('isUnavailableForLegalReasons', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(451);

      expect(response, isUnavailableForLegalReasons);
    });

    test('has the correct describe', () {
      final description = _MockDescription();
      when(() => description.add(any())).thenReturn(description);

      hasStatus(200).describe(description);

      verify(() => description.add('status code is 200')).called(1);
    });

    test('has the correct describe mismatch', () {
      final response = _MockResponse();
      when(() => response.statusCode).thenReturn(201);
      final description = _MockDescription();
      when(() => description.add(any())).thenReturn(description);

      hasStatus(200).describeMismatch(response, description, {}, false);

      verify(() => description.add('status code is 201')).called(1);
    });

    test(
      'has the correct describe mismatch when receiving something '
      'different than a response',
      () {
        final description = _MockDescription();
        when(() => description.add(any())).thenReturn(description);

        hasStatus(200).describeMismatch('', description, {}, false);

        verify(() => description.add('is not a Response')).called(1);
      },
    );
  });
}
