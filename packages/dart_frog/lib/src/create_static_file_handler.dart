import 'package:dart_frog/dart_frog.dart';
import 'package:shelf_static/shelf_static.dart';

/// Creates a [Handler] that serves static files within provided [path].
/// Defaults to the `public` directory.
Handler createStaticFileHandler({String path = 'public'}) {
  return fromShelfHandler(createStaticHandler(path));
}
