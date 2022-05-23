import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) => handler.use(verifyAuthorizationHeader);

Handler verifyAuthorizationHeader(Handler handler) {
  return (context) {
    final hasAuthorizationHeader =
        context.request.headers.containsKey('Authorization');
    return hasAuthorizationHeader
        ? handler(context)
        : Response(HttpStatus.forbidden);
  };
}
