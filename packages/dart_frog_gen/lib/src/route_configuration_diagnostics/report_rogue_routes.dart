import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:path/path.dart' as path;

typedef OnRogueRoute = void Function(String filePath, String idealPath);

void reportRogueRoutes(
  RouteConfiguration configuration, {
  required OnRogueRoute onRogueRoute,
  void Function()? onViolation,
  void Function()? onExit,
}) {
  if (configuration.rogueRoutes.isNotEmpty) {
    onViolation?.call();
    for (final route in configuration.rogueRoutes) {
      final filePath = path.normalize(path.join('routes', route.path));
      final fileDirectory = path.dirname(filePath);
      final idealPath = path.join(
        fileDirectory,
        path.basenameWithoutExtension(filePath),
        'index.dart',
      );
      onRogueRoute(filePath, idealPath);
    }
    onExit?.call();
  }
}
