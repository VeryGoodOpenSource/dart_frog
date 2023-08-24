import 'dart:async';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_test/dart_frog_test.dart';
import 'package:test/test.dart';

/// Expect that all methods except [allowedMethods] are not supported.
Future<void> expectNotAllowedMethods(
  FutureOr<Response> Function(RequestContext) handler, {
  required DartFrogTestContext Function(HttpMethod) contextBuilder,
  required List<HttpMethod> allowedMethods,
}) async {
  final methods = HttpMethod.values.where((m) => !allowedMethods.contains(m));
  for (final method in methods) {
    final context = contextBuilder(method);
    final response = await handler(context.context);
    expect(response, isMethodNotAllowed);
  }
}
