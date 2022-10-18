import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return (context) {
    if (!context.request.headers.containsKey(HttpHeaders.authorizationHeader)) {
      return Response(statusCode: HttpStatus.unauthorized);
    }
    return handler(context);
  };
}
