library dart_frog;

import 'package:path/path.dart' as p;

export 'package:shelf/shelf.dart' show Request, Response;
export 'package:shelf/shelf_io.dart' show serve;
export 'package:shelf_hotreload/shelf_hotreload.dart' show withHotreload;
export 'package:shelf_router/shelf_router.dart' show Router, RouterParams;

/// Converts an import path to a route
String toRoute(String path) {
  var route =
      '/${p.relative(path, from: '../routes').split('.dart').first.replaceAll('index', '')}';

  if (route.length > 1 && route.endsWith('/')) {
    route = route.substring(0, route.length - 1);
  }

  return route;
}
