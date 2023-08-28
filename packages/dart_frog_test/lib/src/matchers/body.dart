import 'package:dart_frog/dart_frog.dart';
import 'package:test/test.dart';

/// Expects the response body to be a JSON object that matches the given
/// [expectedBody].
void expectJsonBody(
  Response response,
  dynamic expectedBody,
) =>
    expect(response.json(), completion(equals(expectedBody)));

/// Expects the response body to match the given [expectedBody].
void expectBody(
  Response response,
  String expectedBody,
) =>
    expect(response.body(), completion(equals(expectedBody)));
