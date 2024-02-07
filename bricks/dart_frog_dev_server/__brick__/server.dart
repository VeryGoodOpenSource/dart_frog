// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, implicit_dynamic_list_literal

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

{{#invokeCustomEntrypoint}}import '../main.dart' as entrypoint;{{/invokeCustomEntrypoint}}
{{#routes}}import '{{{path}}}' as {{#snakeCase}}{{{name}}}{{/snakeCase}};
{{/routes}}
{{#middleware}}import '{{{path}}}' as {{#snakeCase}}{{{name}}}{{/snakeCase}};
{{/middleware}}
void main() async {
  final address = InternetAddress.tryParse('{{{host}}}') ?? InternetAddress.anyIPv6;
  final port = int.tryParse(Platform.environment['PORT'] ?? '{{{port}}}') ?? {{{port}}};{{#invokeCustomInit}}
  await entrypoint.init(address, port);{{/invokeCustomInit}}
  hotReload(() => createServer(address, port));
}

Future<HttpServer> createServer(InternetAddress address, int port) {
  final handler = Cascade(){{#serveStaticFiles}}.add(createStaticFileHandler()){{/serveStaticFiles}}.add(buildRootHandler()).handler;
  {{#invokeCustomEntrypoint}}return entrypoint.run(handler, address, port);{{/invokeCustomEntrypoint}}{{^invokeCustomEntrypoint}}return serve(handler, address, port);{{/invokeCustomEntrypoint}}
}

Handler buildRootHandler() {
  final pipeline = const Pipeline(){{#globalMiddleware}}.addMiddleware({{#snakeCase}}{{{name}}}{{/snakeCase}}.middleware){{/globalMiddleware}};
  final router = Router(){{#directories}}
    ..mount('{{{route}}}', (context{{#directory_params.0}},{{#directory_params}}{{.}},{{/directory_params}}{{/directory_params.0}}) => build{{#pascalCase}}{{{name}}}{{/pascalCase}}Handler({{#directory_params}}{{.}},{{/directory_params}})(context)){{/directories}};
  return pipeline.addHandler(router);
}
{{#directories}}
Handler build{{#pascalCase}}{{{name}}}{{/pascalCase}}Handler({{#directory_params}}String {{.}},{{/directory_params}}) {
  final pipeline = const Pipeline(){{#middleware.0}}{{#middleware}}.addMiddleware({{#snakeCase}}{{{name}}}{{/snakeCase}}.middleware){{/middleware}}{{/middleware.0}};
  final router = Router()
    {{#files}}{{#wildcard}}..mount('{{{route}}}', (context) => {{#snakeCase}}{{{name}}}{{/snakeCase}}.onRequest(context,context.request.url.path)){{/wildcard}}{{^wildcard}}..all('{{{route}}}', (context{{#file_params.0}},{{#file_params}}{{.}},{{/file_params}}{{/file_params.0}}) => {{#snakeCase}}{{{name}}}{{/snakeCase}}.onRequest(context,{{#directory_params}}{{.}},{{/directory_params}}{{#file_params}}{{.}},{{/file_params}})){{/wildcard}}{{/files}};
  return pipeline.addHandler(router);
}
{{/directories}}
