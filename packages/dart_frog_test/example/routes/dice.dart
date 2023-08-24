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
  final random = context.read<Random>();
  return Response.json(
    body: {'value': random.nextInt(6) + 1},
  );
}
