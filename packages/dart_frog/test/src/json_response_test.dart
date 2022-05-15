import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:test/test.dart';

const _statusCodes = <JsonResponse Function(), int>{
  JsonResponse.continue_: HttpStatus.continue_,
  JsonResponse.switchingProtocols: HttpStatus.switchingProtocols,
  JsonResponse.processing: HttpStatus.processing,
  JsonResponse.ok: HttpStatus.ok,
  JsonResponse.created: HttpStatus.created,
  JsonResponse.accepted: HttpStatus.accepted,
  JsonResponse.nonAuthoritativeInformation:
      HttpStatus.nonAuthoritativeInformation,
  JsonResponse.noContent: HttpStatus.noContent,
  JsonResponse.resetContent: HttpStatus.resetContent,
  JsonResponse.partialContent: HttpStatus.partialContent,
  JsonResponse.multiStatus: HttpStatus.multiStatus,
  JsonResponse.alreadyReported: HttpStatus.alreadyReported,
  JsonResponse.imUsed: HttpStatus.imUsed,
  JsonResponse.multipleChoices: HttpStatus.multipleChoices,
  JsonResponse.movedPermanently: HttpStatus.movedPermanently,
  JsonResponse.found: HttpStatus.found,
  JsonResponse.movedTemporarily: HttpStatus.movedTemporarily,
  JsonResponse.seeOther: HttpStatus.seeOther,
  JsonResponse.notModified: HttpStatus.notModified,
  JsonResponse.useProxy: HttpStatus.useProxy,
  JsonResponse.temporaryRedirect: HttpStatus.temporaryRedirect,
  JsonResponse.permanentRedirect: HttpStatus.permanentRedirect,
  JsonResponse.badRequest: HttpStatus.badRequest,
  JsonResponse.unauthorized: HttpStatus.unauthorized,
  JsonResponse.paymentRequired: HttpStatus.paymentRequired,
  JsonResponse.forbidden: HttpStatus.forbidden,
  JsonResponse.notFound: HttpStatus.notFound,
  JsonResponse.methodNotAllowed: HttpStatus.methodNotAllowed,
  JsonResponse.notAcceptable: HttpStatus.notAcceptable,
  JsonResponse.proxyAuthenticationRequired:
      HttpStatus.proxyAuthenticationRequired,
  JsonResponse.requestTimeout: HttpStatus.requestTimeout,
  JsonResponse.conflict: HttpStatus.conflict,
  JsonResponse.gone: HttpStatus.gone,
  JsonResponse.lengthRequired: HttpStatus.lengthRequired,
  JsonResponse.preconditionFailed: HttpStatus.preconditionFailed,
  JsonResponse.requestEntityTooLarge: HttpStatus.requestEntityTooLarge,
  JsonResponse.requestUriTooLong: HttpStatus.requestUriTooLong,
  JsonResponse.unsupportedMediaType: HttpStatus.unsupportedMediaType,
  JsonResponse.requestedRangeNotSatisfiable:
      HttpStatus.requestedRangeNotSatisfiable,
  JsonResponse.expectationFailed: HttpStatus.expectationFailed,
  JsonResponse.misdirectedRequest: HttpStatus.misdirectedRequest,
  JsonResponse.unprocessableEntity: HttpStatus.unprocessableEntity,
  JsonResponse.locked: HttpStatus.locked,
  JsonResponse.failedDependency: HttpStatus.failedDependency,
  JsonResponse.upgradeRequired: HttpStatus.upgradeRequired,
  JsonResponse.preconditionRequired: HttpStatus.preconditionRequired,
  JsonResponse.tooManyRequests: HttpStatus.tooManyRequests,
  JsonResponse.requestHeaderFieldsTooLarge:
      HttpStatus.requestHeaderFieldsTooLarge,
  JsonResponse.connectionClosedWithoutResponse:
      HttpStatus.connectionClosedWithoutResponse,
  JsonResponse.unavailableForLegalReasons:
      HttpStatus.unavailableForLegalReasons,
  JsonResponse.clientClosedRequest: HttpStatus.clientClosedRequest,
  JsonResponse.internalServerError: HttpStatus.internalServerError,
  JsonResponse.notImplemented: HttpStatus.notImplemented,
  JsonResponse.badGateway: HttpStatus.badGateway,
  JsonResponse.serviceUnavailable: HttpStatus.serviceUnavailable,
  JsonResponse.gatewayTimeout: HttpStatus.gatewayTimeout,
  JsonResponse.httpVersionNotSupported: HttpStatus.httpVersionNotSupported,
  JsonResponse.variantAlsoNegotiates: HttpStatus.variantAlsoNegotiates,
  JsonResponse.insufficientStorage: HttpStatus.insufficientStorage,
  JsonResponse.loopDetected: HttpStatus.loopDetected,
  JsonResponse.notExtended: HttpStatus.notExtended,
  JsonResponse.networkAuthenticationRequired:
      HttpStatus.networkAuthenticationRequired,
  JsonResponse.networkConnectTimeoutError:
      HttpStatus.networkConnectTimeoutError,
};

void main() {
  group('JsonResponse', () {
    for (final entry in _statusCodes.entries) {
      test('has correct status code (${entry.value})', () {
        expect(entry.key().statusCode, equals(entry.value));
      });
    }
  });
}
