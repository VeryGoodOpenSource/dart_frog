import 'dart:io';

import 'package:path/path.dart' as path;

/// Extension on [FileSystemEntity] which provides support
/// for determining whether an entity is a route.
extension IsRouteExtension on FileSystemEntity {
  /// Returns whether the current entity is a valid route.ss
  bool get isRoute {
    return this is File &&
        path.basename(this.path).endsWith('.dart') &&
        path.basename(this.path) != '_middleware.dart';
  }
}
