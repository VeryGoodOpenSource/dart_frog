import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

void reportRogueRoutes(
  HookContext context,
  RouteConfiguration configuration,
) {
  if (configuration.rogueRoutes.isNotEmpty) {
    context.logger.info('');
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
  }
}
