import 'dart:io';
import 'dart:math';

import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return switch (context.request.method) {
    HttpMethod.post => _onPost(context),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Response _onPost(RequestContext context) {
  final rng = context.read<Random>();
  return Response.json(
    body: {'value': rng.nextInt(6) + 1},
  );
}
