import 'dart:developer';

import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final counter = context.read<Counter>()..value += 1;
  return Response(
    body: 'You have requested this route ${counter.value.toInt()} time(s).',
  );
}
