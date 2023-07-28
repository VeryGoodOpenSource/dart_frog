import 'dart:async';

import 'package:dart_frog/dart_frog.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockRequestContext extends Mock implements RequestContext {}

/// A test that can be used to test a Dart Frog handler.
@isTest
void testRouteHandler(
  String message, {
  required FutureOr<Response> Function(RequestContext request) onRequest,
  required Request request,
  FutureOr<void> Function(RequestContext)? setUp,
  FutureOr<void> Function(Response)? expect,
}) {
  test(
    '${request.method.name.toUpperCase()} ${request.url.path}: $message',
    () async {
      final requestContext = _MockRequestContext();

      when(() => requestContext.request).thenReturn(request);

      await setUp?.call(requestContext);
      final response = await onRequest(requestContext);
      await expect?.call(response);
    },
  );
}
