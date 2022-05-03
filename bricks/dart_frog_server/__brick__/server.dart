import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:path/path.dart' as path;

{{#routes}}import '{{{path}}}' as {{#snakeCase}}{{{alias}}}{{/snakeCase}};
{{/routes}}

void main() => withHotreload(() => createServer());

Future<HttpServer> createServer() async {
  final router = Router(){{#routes}}..all(toRoute('{{{path}}}'), {{#snakeCase}}{{{alias}}}{{/snakeCase}}.onRequest){{/routes}};
  return serve(router, 'localhost', int.parse(Platform.environment["PORT"] ?? '8080'));  
}
