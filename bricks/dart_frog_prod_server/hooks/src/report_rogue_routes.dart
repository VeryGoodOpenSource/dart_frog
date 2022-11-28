import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

void reportRogueRoutes(
  HookContext context,
  RouteConfiguration configuration,
  void Function(int exitCode) exit,
) {
  if (configuration.rogueRoutes.isNotEmpty) {
    for (final route in configuration.rogueRoutes) {
      final filePath = path.normalize(path.join('routes', route.path));
      final fileDirectory = path.dirname(filePath);
      final idealPath = path.join(
        fileDirectory,
        path.basenameWithoutExtension(filePath),
        'index.dart',
      );
      context.logger.err(
        '''Rogue route detected.${defaultForeground.wrap(' ')}Rename ${lightCyan.wrap(filePath)} to ${lightCyan.wrap(idealPath)}.''',
      );
    }
    exit(1);
  }
}
