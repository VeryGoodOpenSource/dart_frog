import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

Future<void> run(HookContext context) async {
  final routesDirectory =
      Directory(path.join(Directory.current.path, 'routes'));

  if (!routesDirectory.existsSync()) {
    context.logger.err('Could not find directory ${routesDirectory.path}');
    exit(1);
  }

  final routes = routesDirectory
      .listSync(recursive: true)
      .where((entity) => entity.isRoute)
      .map((entity) =>
          path.join('..', path.relative(entity.path).replaceAll(r'\', '/')))
      .toList();

  context.vars = {'routes': routes};
}

extension on FileSystemEntity {
  bool get isRoute {
    return this is File && path.basename(this.path).endsWith('.dart');
  }
}
