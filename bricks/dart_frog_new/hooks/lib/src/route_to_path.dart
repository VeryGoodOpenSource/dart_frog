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
