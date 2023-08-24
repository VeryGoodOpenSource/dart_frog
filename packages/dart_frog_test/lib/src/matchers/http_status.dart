import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:test/test.dart';

/// Asserts if the response is a [HttpStatus.methodNotAllowed].
Matcher get isMethodNotAllowed => hasStatus(HttpStatus.methodNotAllowed);

/// Asserts if the response is a [HttpStatus.internalServerError].
Matcher get isInternalServerError => hasStatus(HttpStatus.internalServerError);

/// Asserts if the response is a [HttpStatus.forbidden].
Matcher get isForbidden => hasStatus(HttpStatus.forbidden);

/// Asserts if the response is a [HttpStatus.unauthorized].
Matcher get isUnauthorized => hasStatus(HttpStatus.unauthorized);

/// Asserts if the response is a [HttpStatus.notFound].
Matcher get isNotFound => hasStatus(HttpStatus.notFound);

/// Asserts if the response is a [HttpStatus.created].
Matcher get isCreated => hasStatus(HttpStatus.created);

/// Asserts if the response is a [HttpStatus.badRequest].
Matcher get isBadRequest => hasStatus(HttpStatus.badRequest);

/// Asserts if the response is a [HttpStatus.ok].
Matcher get isOk => hasStatus(HttpStatus.ok);

/// Asserts if the response is a [HttpStatus.accepted].
Matcher get isAccepted => hasStatus(HttpStatus.accepted);

/// Asserts if the response is a [HttpStatus.noContent].
Matcher get isNoContent => hasStatus(HttpStatus.noContent);

/// Asserts if the response is a [HttpStatus.movedPermanently].
Matcher get isMovedPermanently => hasStatus(HttpStatus.movedPermanently);

/// Asserts if the response is a [HttpStatus.found].
Matcher get isFound => hasStatus(HttpStatus.found);

/// Asserts if the response is a [HttpStatus.seeOther].
Matcher get isSeeOther => hasStatus(HttpStatus.seeOther);

/// Asserts if the response is a [HttpStatus.notModified].
Matcher get isNotModified => hasStatus(HttpStatus.notModified);

/// Asserts if the response is a [HttpStatus.conflict].
Matcher get isConflict => hasStatus(HttpStatus.conflict);

/// Asserts if the response is a [HttpStatus.notImplemented].
Matcher get isNotImplemented => hasStatus(HttpStatus.notImplemented);

/// Asserts if the response is a [HttpStatus.serviceUnavailable].
Matcher get isServiceUnavailable => hasStatus(HttpStatus.serviceUnavailable);

/// Asserts if the response is a [HttpStatus.badGateway].
Matcher get isBadGateway => hasStatus(HttpStatus.badGateway);

/// Asserts if the response is a [HttpStatus.gatewayTimeout].
Matcher get isGatewayTimeout => hasStatus(HttpStatus.gatewayTimeout);

/// Asserts if the response is a [HttpStatus.requestTimeout].
Matcher get isRequestTimeout => hasStatus(HttpStatus.requestTimeout);

/// Asserts if the response is a [HttpStatus.tooManyRequests].
Matcher get isTooManyRequests => hasStatus(HttpStatus.tooManyRequests);

/// Asserts if the response is a [HttpStatus.notAcceptable].
Matcher get isNotAcceptable => hasStatus(HttpStatus.notAcceptable);

/// Asserts if the response is a [HttpStatus.preconditionFailed].
Matcher get isPreconditionFailed => hasStatus(HttpStatus.preconditionFailed);

/// Asserts if the response is a [HttpStatus.requestEntityTooLarge].
Matcher get isRequestEntityTooLarge =>
    hasStatus(HttpStatus.requestEntityTooLarge);

/// Asserts if the response is a [HttpStatus.unsupportedMediaType].
Matcher get isUnsupportedMediaType =>
    hasStatus(HttpStatus.unsupportedMediaType);

/// Asserts if the response is a [HttpStatus.requestedRangeNotSatisfiable].
Matcher get isRequestedRangeNotSatisfiable =>
    hasStatus(HttpStatus.requestedRangeNotSatisfiable);

/// Asserts if the response is a [HttpStatus.expectationFailed].
Matcher get isExpectationFailed => hasStatus(HttpStatus.expectationFailed);

/// Asserts if the response is a [HttpStatus.failedDependency].
Matcher get isFailedDependency => hasStatus(HttpStatus.failedDependency);

/// Asserts if the response is a [HttpStatus.upgradeRequired].
Matcher get isUpgradeRequired => hasStatus(HttpStatus.upgradeRequired);

/// Asserts if the response is a [HttpStatus.preconditionRequired].
Matcher get isPreconditionRequired =>
    hasStatus(HttpStatus.preconditionRequired);

/// Asserts if the response is a [HttpStatus.requestHeaderFieldsTooLarge].
Matcher get isRequestHeaderFieldsTooLarge =>
    hasStatus(HttpStatus.requestHeaderFieldsTooLarge);

/// Asserts if the response is a [HttpStatus.unavailableForLegalReasons].
Matcher get isUnavailableForLegalReasons =>
    hasStatus(HttpStatus.unavailableForLegalReasons);

/// Asserts if the response status code is [statusCode].
Matcher hasStatus(int statusCode) => _ResponseStatusIs(
      statusCode: statusCode,
    );

class _ResponseStatusIs extends Matcher {
  const _ResponseStatusIs({
    required this.statusCode,
  });

  final int statusCode;

  @override
  bool matches(Object? item, Map<dynamic, dynamic> _) {
    return item is Response && item.statusCode == statusCode;
  }

  @override
  Description describe(Description description) {
    return description.add('status code is $statusCode');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is! Response) {
      return mismatchDescription.add('is not a Response');
    } else {
      return mismatchDescription.add('status code is ${item.statusCode}');
    }
  }
}
