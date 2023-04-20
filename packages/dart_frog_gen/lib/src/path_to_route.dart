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
  final normalizedPath = path.replaceAll(r'\', '/');
  final relativePath =
      p.relative(normalizedPath, from: '../routes').replaceAll(r'\', '/');
  final route = '/${relativePath.split('.dart').first.replaceAll('index', '')}';

  if (route.length > 1 && route.endsWith('/')) {
    return route.substring(0, route.length - 1);
  }

  return route;
}

/// Convert a route to a file path.
///
/// If [preferIndex] is true, the path will be converted to a directory path
/// with an index dart file.
///
/// ```
/// "/" -> "./routes/index.dart" (if preferIndex is false)
/// "/" -> "./routes/index.dart" (if preferIndex is true)
/// "/hello" -> "./routes/hello.dart" (if preferIndex is false)
/// "/hello" -> "./routes/hello/index.dart" (if preferIndex is true)
/// "/hello/[name]" -> "./routes/hello/[name].dart" (if preferIndex is false)
/// "/hello/[name]" -> "./routes/hello/[name]/index.dart" (if preferIndex is true)
String routeToPath(
  String route, {
  bool preferIndex = false,
  String preamble = 'routes',
}) {
  if (route == '/') {
    return '$preamble/index.dart';
  }

  final path =
      route.split('/').where((element) => element.isNotEmpty).join('/');

  if (preferIndex) {
    final pathWithIndex = '$path/index.dart';
    return '$preamble/$pathWithIndex';
  }

  final pathWithExtension = '$path.dart';
  return '$preamble/$pathWithExtension';
}
