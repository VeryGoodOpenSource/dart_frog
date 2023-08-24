import 'dart:math';

import 'package:dart_frog/dart_frog.dart';
final Random _random = Random()

Handler middleware(Handler handler) {
  return handler.use(provider<Random>((_) => _random));
}
