import 'package:path/path.dart' as p;

/// Convert a file path to an API route.
///
/// ```
/// "../routes/index.dart" -> "/"
/// "../routes/hello.dart" -> "/hello"
/// "../routes/hello/world.dart" -> "/hello/world"
/// "../routes/hello/<name>.dart" -> "/hello/<name>"
/// ```
String pathToRoute(String path) {
  final relativePath =
      p.relative(path, from: '../routes').replaceAll(r'\', '/');
  final route = '/${relativePath.split('.dart').first.replaceAll('index', '')}';

  if (route.length > 1 && route.endsWith('/')) {
    return route.substring(0, route.length - 1);
  }

  return route;
}
