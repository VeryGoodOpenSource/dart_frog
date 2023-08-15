import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:test/test.dart';

/// A matcher that checkes if the response is a
/// [HttpStatus.internalServerError].
Matcher get isInternalServerError => hasStatus(HttpStatus.internalServerError);

/// A matcher that checkes if the response is a [HttpStatus.forbidden].
Matcher get isForbidden => hasStatus(HttpStatus.forbidden);

/// A matcher that checkes if the response is a [HttpStatus.unauthorized].
Matcher get isUnauthorized => hasStatus(HttpStatus.unauthorized);

/// A matcher that checkes if the response is a [HttpStatus.notFound].
Matcher get isNotFound => hasStatus(HttpStatus.notFound);

/// A matcher that checkes if the response is a [HttpStatus.created].
Matcher get isCreated => hasStatus(HttpStatus.created);

/// A matcher that checkes if the response is a [HttpStatus.badRequest].
Matcher get isBadRequest => hasStatus(HttpStatus.badRequest);

/// A matcher that checkes if the response is a [HttpStatus.ok].
Matcher get isOk => hasStatus(HttpStatus.ok);

/// A matcher that checkes if the response status code is [statusCode].
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
