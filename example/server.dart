// ignore_for_file: prefer_single_quotes, implicit_dynamic_list_literal, prefer_const_constructors, lines_longer_than_80_chars, avoid_dynamic_calls

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:path/path.dart' as path;

import './routes/index.dart' as r1;
import './routes/hello.dart' as r2;
import './routes/api/v1/index.dart' as r3;

void main() => withHotreload(createServer);

Future<HttpServer> createServer() async {
  final ip = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final handler = buildRouterGraph();
  return serve(handler, ip, port);
}

Handler buildRouterGraph() {
  return Router()
    ..mount('/', (r) => buildD1Router()(r))
    ..mount('/api', (r) => buildD2Router()(r))
    ..mount('/api/v1', (r) => buildD3Router()(r));
}

Handler buildD1Router() {
  var pipeline = Pipeline();
  final router = Router()
    ..all('/', r1.onRequest)
    ..all('/hello', r2.onRequest);
  return pipeline.addHandler(router);
}

Handler buildD2Router() {
  var pipeline = Pipeline();
  pipeline = pipeline.addMiddleware(
    (innerHandler) => (request) async {
      final name = 'd2';
      print('$name onRequest');
      final response = await innerHandler(request);
      print('$name onResponse');
      return response;
    },
  );
  final router = Router();
  return pipeline.addHandler(router);
}

Handler buildD3Router() {
  var pipeline = Pipeline();
  final router = Router()..all('/', r3.onRequest);
  return pipeline.addHandler(router);
}
