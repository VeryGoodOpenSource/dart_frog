import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) => handler.use(verifyAuthorizationHeader);

Handler verifyAuthorizationHeader(Handler handler) {
  return (request) {
    final hasAuthorizationHeader = request.headers.containsKey('Authorization');
    return hasAuthorizationHeader
        ? handler(request)
        : Response(HttpStatus.forbidden);
  };
}
