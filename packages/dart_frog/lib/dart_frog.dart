library dart_frog;

import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

export 'package:shelf/shelf.dart' show Request, Response;
export 'package:shelf_router/shelf_router.dart' show Router;

/// {@template app}
/// A DartFrog application.
/// {endtemplate}
class App {
  /// {@macro app}
  const App();

  /// Create an [HttpServer] on [port] with the provided [handler].
  Future<HttpServer> serve(shelf.Handler handler, {int? port}) async {
    port ??= int.parse(Platform.environment['PORT'] ?? '8080');
    return shelf_io.serve(
      const shelf.Pipeline().addHandler(handler),
      InternetAddress.anyIPv4,
      port,
    );
  }
}
