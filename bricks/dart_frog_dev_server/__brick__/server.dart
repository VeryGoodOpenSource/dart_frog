// ignore_for_file: prefer_single_quotes, implicit_dynamic_list_literal, prefer_const_constructors, lines_longer_than_80_chars, avoid_dynamic_calls

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:path/path.dart' as path;

{{#routes}}import '{{{path}}}' as {{#snakeCase}}{{{name}}}{{/snakeCase}};
{{/routes}}
{{#middleware}}import '{{{path}}}' as {{#snakeCase}}{{{name}}}{{/snakeCase}};
{{/middleware}}
void main() => withHotreload(createServer);

Future<HttpServer> createServer() async {
  final ip = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final handler = buildHandler();
  return serve(handler, ip, port);
}

Handler buildHandler() {
  var pipeline = const Pipeline();{{#globalMiddleware}}pipeline = pipeline.addMiddleware({{#snakeCase}}{{{name}}}{{/snakeCase}}.middleware);{{/globalMiddleware}}
  final router = Router(){{#directories}}
    ..mount('{{{route}}}', (r) => build{{#pascalCase}}{{{name}}}{{/pascalCase}}Router()(r)){{/directories}};
  return pipeline.addHandler(router);
}
{{#directories}}
Handler build{{#pascalCase}}{{{name}}}{{/pascalCase}}Router() {
  var pipeline = const Pipeline();{{#middleware}}pipeline = pipeline.addMiddleware({{#snakeCase}}{{{name}}}{{/snakeCase}}.middleware);{{/middleware}}
  final router = Router()
    {{#files}}..all('{{{route}}}', {{#snakeCase}}{{{name}}}{{/snakeCase}}.onRequest){{/files}};
  return pipeline.addHandler(router);
}
{{/directories}}