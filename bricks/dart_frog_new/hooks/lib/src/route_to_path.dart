import 'package:path/path.dart' as path;

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
  path.Context? pathContext,
}) {
  final context = pathContext ?? path.context;
  final separator = context.separator;

  if (route == '/') {
    return '$preamble${separator}index.dart';
  }

  final p =
      route.split('/').where((element) => element.isNotEmpty).join(separator);

  if (preferIndex) {
    final pathWithIndex = context.join(p, 'index.dart');
    return context.join(preamble, pathWithIndex);
  }

  final pathWithExtension = '$p.dart';
  return context.join(preamble, pathWithExtension);
}
