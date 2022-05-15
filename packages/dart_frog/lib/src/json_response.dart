import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

/// {@template json_response}
/// A [Response] which includes a json response body.
/// {@endtemplate}
class JsonResponse extends Response {
  JsonResponse._({
    int statusCode = HttpStatus.ok,
    Map<String, dynamic>? body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : super(
          statusCode,
          body: body != null ? json.encode(body) : null,
          headers: {
            ...headers,
            HttpHeaders.contentTypeHeader: ContentType.json.value,
          },
        );

  /// {@macro json_response}
  JsonResponse.continue_({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.continue_,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.switchingProtocols({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.switchingProtocols,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.processing({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.processing,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.ok({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.ok,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.created({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.created,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.accepted({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.accepted,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.nonAuthoritativeInformation({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.nonAuthoritativeInformation,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.noContent({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.noContent,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.resetContent({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.resetContent,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.partialContent({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.partialContent,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.multiStatus({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.multiStatus,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.alreadyReported({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.alreadyReported,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.imUsed({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.imUsed,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.multipleChoices({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.multipleChoices,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.movedPermanently({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.movedPermanently,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.found({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.found,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.movedTemporarily({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.movedTemporarily,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.seeOther({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.seeOther,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.notModified({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.notModified,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.useProxy({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.useProxy,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.temporaryRedirect({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.temporaryRedirect,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.permanentRedirect({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.permanentRedirect,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.badRequest({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.badRequest,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.unauthorized({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.unauthorized,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.paymentRequired({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.paymentRequired,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.forbidden({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.forbidden,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.notFound({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.notFound,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.methodNotAllowed({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.methodNotAllowed,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.notAcceptable({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.notAcceptable,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.proxyAuthenticationRequired({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.proxyAuthenticationRequired,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.requestTimeout({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.requestTimeout,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.conflict({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.conflict,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.gone({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.gone,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.lengthRequired({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.lengthRequired,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.preconditionFailed({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.preconditionFailed,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.requestEntityTooLarge({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.requestEntityTooLarge,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.requestUriTooLong({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.requestUriTooLong,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.unsupportedMediaType({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.unsupportedMediaType,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.requestedRangeNotSatisfiable({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.requestedRangeNotSatisfiable,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.expectationFailed({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.expectationFailed,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.misdirectedRequest({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.misdirectedRequest,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.unprocessableEntity({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.unprocessableEntity,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.locked({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.locked,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.failedDependency({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.failedDependency,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.upgradeRequired({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.upgradeRequired,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.preconditionRequired({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.preconditionRequired,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.tooManyRequests({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.tooManyRequests,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.requestHeaderFieldsTooLarge({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.requestHeaderFieldsTooLarge,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.connectionClosedWithoutResponse({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.connectionClosedWithoutResponse,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.unavailableForLegalReasons({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.unavailableForLegalReasons,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.clientClosedRequest({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.clientClosedRequest,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.internalServerError({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.internalServerError,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.notImplemented({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.notImplemented,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.badGateway({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.badGateway,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.serviceUnavailable({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.serviceUnavailable,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.gatewayTimeout({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.gatewayTimeout,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.httpVersionNotSupported({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.httpVersionNotSupported,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.variantAlsoNegotiates({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.variantAlsoNegotiates,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.insufficientStorage({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.insufficientStorage,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.loopDetected({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.loopDetected,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.notExtended({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.notExtended,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.networkAuthenticationRequired({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.networkAuthenticationRequired,
          body: body,
          headers: headers,
        );

  /// {@macro json_response}
  JsonResponse.networkConnectTimeoutError({
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
  }) : this._(
          statusCode: HttpStatus.networkConnectTimeoutError,
          body: body,
          headers: headers,
        );
}
