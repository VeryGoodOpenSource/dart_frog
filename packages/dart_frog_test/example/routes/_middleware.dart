import 'dart:math';

import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler.use(provider<Random>((_) => Random()));
}
