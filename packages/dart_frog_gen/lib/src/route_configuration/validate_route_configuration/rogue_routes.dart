import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:path/path.dart' as path;

/// Type definition for callbacks that report rogue routes.
typedef OnRogueRoute = void Function(String filePath, String idealPath);

/// Reports existence of rogue routes on a [RouteConfiguration].
void reportRogueRoutes(
  RouteConfiguration configuration, {
  /// Callback called when any rogue route is found.
  void Function()? onViolationStart,

  /// Callback called for each rogue route found.
  OnRogueRoute? onRogueRoute,

  /// Callback called when any rogue route is found.
  void Function()? onViolationEnd,
}) {
  if (configuration.rogueRoutes.isNotEmpty) {
    onViolationStart?.call();
    for (final route in configuration.rogueRoutes) {
      final filePath = path.normalize(path.join('routes', route.path));
      final fileDirectory = path.dirname(filePath);
      final idealPath = path.join(
        fileDirectory,
        path.basenameWithoutExtension(filePath),
        'index.dart',
      );
      onRogueRoute?.call(filePath, idealPath);
    }
    onViolationEnd?.call();
  }
}
