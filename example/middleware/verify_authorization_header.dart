import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Handler verifyAuthorizationHeader(Handler handler) {
  return (request) {
    final hasAuthorizationHeader = request.headers.containsKey('Authorization');
    return hasAuthorizationHeader
        ? handler(request)
        : Response(HttpStatus.forbidden);
  };
}
