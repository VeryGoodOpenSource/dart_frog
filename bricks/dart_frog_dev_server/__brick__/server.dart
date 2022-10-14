// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, implicit_dynamic_list_literal

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

{{#invokeCustomEntrypoint}}import '../main.dart' as entrypoint;{{/invokeCustomEntrypoint}}
{{#routes}}import '{{{path}}}' as {{#snakeCase}}{{{name}}}{{/snakeCase}};
{{/routes}}
{{#middleware}}import '{{{path}}}' as {{#snakeCase}}{{{name}}}{{/snakeCase}};
{{/middleware}}
void main() => hotReload(createServer);

Future<HttpServer> createServer() {
  final ip = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '{{port}}');
  final handler = Cascade(){{#serveStaticFiles}}.add(createStaticFileHandler()){{/serveStaticFiles}}.add(buildRootHandler()).handler;
  {{#invokeCustomEntrypoint}}return entrypoint.run(handler, ip, port);{{/invokeCustomEntrypoint}}{{^invokeCustomEntrypoint}}return serve(handler, ip, port);{{/invokeCustomEntrypoint}}
}

Handler buildRootHandler() {
  final pipeline = const Pipeline(){{#globalMiddleware}}.addMiddleware({{#snakeCase}}{{{name}}}{{/snakeCase}}.middleware){{/globalMiddleware}};
  final router = Router(){{#directories}}
    ..mount('{{{route}}}', (ctx, {{#directory_params}}{{.}},{{/directory_params}}) => build{{#pascalCase}}{{{name}}}{{/pascalCase}}Handler({{#directory_params}}{{.}},{{/directory_params}})(ctx)){{/directories}};
  return pipeline.addHandler(router);
}
{{#directories}}
Handler build{{#pascalCase}}{{{name}}}{{/pascalCase}}Handler({{#directory_params}}String {{.}},{{/directory_params}}) {
  {{#middleware}}final pipeline = const Pipeline(){{#middleware}}.addMiddleware({{#snakeCase}}{{{name}}}{{/snakeCase}}.middleware);{{/middleware}}{{/middleware}}{{^middleware}}const pipeline = Pipeline();{{/middleware}}
  final router = Router()
    {{#files}}..all('{{{route}}}', (ctx,{{#file_params}}{{.}},{{/file_params}}) => {{#snakeCase}}{{{name}}}{{/snakeCase}}.onRequest(ctx, {{#directory_params}}{{.}},{{/directory_params}}{{#file_params}}{{.}},{{/file_params}})){{/files}};
  return pipeline.addHandler(router);
}
{{/directories}}