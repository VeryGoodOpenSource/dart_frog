// ignore_for_file: prefer_single_quotes, implicit_dynamic_list_literal, prefer_const_constructors, lines_longer_than_80_chars, avoid_dynamic_calls, library_prefixes, directives_ordering

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

{{#routes}}import '{{{path}}}' as {{#snakeCase}}{{{name}}}{{/snakeCase}};
{{/routes}}
{{#middleware}}import '{{{path}}}' as {{#snakeCase}}{{{name}}}{{/snakeCase}};
{{/middleware}}
void main() => hotReload(createServer);

Future<HttpServer> createServer() {
  final ip = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '{{port}}');
  final handler = buildRootHandler();
  return serve(handler, ip, port);
}

Handler buildRootHandler() {
  final pipeline = const Pipeline(){{#globalMiddleware}}.addMiddleware({{#snakeCase}}{{{name}}}{{/snakeCase}}.middleware){{/globalMiddleware}};
  final router = Router(){{#directories}}
    ..mount('{{{route}}}', (r) => build{{#pascalCase}}{{{name}}}{{/pascalCase}}Handler()(r)){{/directories}};
  return pipeline.addHandler(router);
}
{{#directories}}
Handler build{{#pascalCase}}{{{name}}}{{/pascalCase}}Handler() {
  {{#middleware}}final pipeline = const Pipeline(){{#middleware}}.addMiddleware({{#snakeCase}}{{{name}}}{{/snakeCase}}.middleware);{{/middleware}}{{/middleware}}{{^middleware}}const pipeline = Pipeline();{{/middleware}}
  final router = Router()
    {{#files}}..all('{{{route}}}', {{#snakeCase}}{{{name}}}{{/snakeCase}}.onRequest){{/files}};
  return pipeline.addHandler(router);
}
{{/directories}}