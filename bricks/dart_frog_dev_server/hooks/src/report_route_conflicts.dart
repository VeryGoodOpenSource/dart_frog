import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

void reportRouteConflicts(
  HookContext context,
  RouteConfiguration configuration,
) {
  final conflictingEndpoints =
      configuration.endpoints.entries.where((entry) => entry.value.length > 1);
  if (conflictingEndpoints.isNotEmpty) {
    context.logger.info('');
    for (final conflict in conflictingEndpoints) {
      final originalFilePath = path.normalize(
        path.join('routes', conflict.value.first.path),
      );
      final conflictingFilePath = path.normalize(
        path.join('routes', conflict.value.last.path),
      );
      context.logger.err(
        '''Route conflict detected. ${lightCyan.wrap(originalFilePath)} and ${lightCyan.wrap(conflictingFilePath)} both resolve to ${lightCyan.wrap(conflict.key)}.''',
      );
    }
  }
}
