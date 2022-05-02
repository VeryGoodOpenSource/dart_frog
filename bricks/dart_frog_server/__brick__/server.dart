import 'package:dart_frog/dart_frog.dart';
import 'package:path/path.dart' as path;

{{#routes}}import '{{{.}}}' as {{#snakeCase}}{{{.}}}{{/snakeCase}};
{{/routes}}

Future<void> main() async {
  final router = Router(){{#routes}}..all('{{{.}}}'.toRoute(), {{#snakeCase}}{{{.}}}{{/snakeCase}}.onRequest){{/routes}};
  final app = App();
  final server = await app.serve(router);
}

extension on String {
  String toRoute() {
    var route =
        '/${path.relative(this, from: '../routes').split('.dart').first.replaceAll('index', '')}';

    if (route.length > 1 && route.endsWith('/')) {
      route = route.substring(0, route.length - 1);
    }

    return route;
  }
}
