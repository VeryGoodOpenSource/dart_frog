import 'dart:async';

import 'package:dart_frog/dart_frog.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

/// A test that can be used to test a Dart Frog handler.
@isTest
void testDartFrog(
  String message, {
  required String url,
  required FutureOr<Response> Function(RequestContext request) onRequest,
  HttpMethod method = HttpMethod.get,
  Map<String, String>? headers,
  dynamic requestJson,
  String? requestBody,
  FutureOr<void> Function(RequestContext)? setUp,
  FutureOr<void> Function(Response)? expect,
}) {
  assert(
    !(requestJson != null && requestBody != null),
    'Both a request json and a request body were provided. '
    'Only one can be provided.',
  );
  test('${method.name.toUpperCase()} $url: $message', () async {
    final requestContext = _MockRequestContext();

    final request = _MockRequest();

    when(() => request.method).thenReturn(method);
    when(() => request.url).thenReturn(Uri.parse(url));
    when(() => request.headers).thenReturn(headers ?? {});

    if (requestBody != null) {
      when(request.body).thenAnswer((_) async => requestBody);
    }

    if (requestJson != null) {
      when(request.json).thenAnswer((_) async => requestJson);
    }

    when(() => requestContext.request).thenReturn(request);

    await setUp?.call(requestContext);
    final response = await onRequest(requestContext);
    await expect?.call(response);
  });
}
