import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler.use(_requestValidator());
}

Middleware _requestValidator() {
  return (handler) {
    return (context) async {
      final request = context.request;

      if (request.method != HttpMethod.post) {
        return Response(statusCode: HttpStatus.methodNotAllowed);
      }

      final body = await request.body();

      if (body.isEmpty) return Response(statusCode: HttpStatus.badRequest);

      return handler(context);
    };
  };
}
