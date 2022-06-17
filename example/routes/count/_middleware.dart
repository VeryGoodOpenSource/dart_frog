import 'dart:developer';

import 'package:dart_frog/dart_frog.dart';

final _counter = Counter('counter', 'a simple request counter');

Handler middleware(Handler handler) {
  return handler.use(provider<Counter>((_) => _counter));
}
