// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, implicit_dynamic_list_literal

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

{{#invokeCustomEntrypoint}}import '../main.dart' as entrypoint;{{/invokeCustomEntrypoint}}
{{#routes}}import '{{{path}}}' as {{#snakeCase}}{{{name}}}{{/snakeCase}};
{{/routes}}
{{#middleware}}import '{{{path}}}' as {{#snakeCase}}{{{name}}}{{/snakeCase}};
{{/middleware}}
void main() => createServer();

Future<HttpServer> createServer() async {
  final ip = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final handler = Cascade(){{#serveStaticFiles}}.add(createStaticFileHandler()){{/serveStaticFiles}}.add(buildRootHandler()).handler;
  final server = await {{#invokeCustomEntrypoint}}entrypoint.run(handler, ip, port){{/invokeCustomEntrypoint}}{{^invokeCustomEntrypoint}}serve(handler, ip, port){{/invokeCustomEntrypoint}};
  print('\x1B[92m✓\x1B[0m Running on http://${server.address.host}:${server.port}');
  return server;
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
    {{#files}}..all('{{{route}}}', (context{{#file_params.0}},{{#file_params}}{{.}},{{/file_params}}{{/file_params.0}}) => {{#snakeCase}}{{{name}}}{{/snakeCase}}.onRequest(context{{#directory_params.0}},{{#directory_params}}{{.}},{{/directory_params}}{{/directory_params.0}}{{#file_params.0}},{{#file_params}}{{.}},{{/file_params}}{{/file_params.0}})){{/files}};
  return pipeline.addHandler(router);
}
{{/directories}}