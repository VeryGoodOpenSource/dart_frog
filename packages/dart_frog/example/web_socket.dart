import 'dart:async';

import 'package:dart_frog/dart_frog.dart';

FutureOr<Response> onRequest(RequestContext context) async {
  return upgradeToWebSocket(context, (socket) {
    socket.listen((event) {
      socket.send('Hello from Dart Frog - Web Socket 🐸');
    });
  });
}
