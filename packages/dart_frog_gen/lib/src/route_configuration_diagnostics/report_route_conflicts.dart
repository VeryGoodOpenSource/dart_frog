import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:path/path.dart' as path;

typedef OnRouteConflict = void Function(
  String originalFilePath,
  String conflictingFilePath,
  String conflictingEndpoint,
);

void reportRouteConflicts(
  RouteConfiguration configuration, {
  required OnRouteConflict onRouteConflict,
  void Function()? onViolation,
  void Function()? onExit,
}) {
  final conflictingEndpoints =
      configuration.endpoints.entries.where((entry) => entry.value.length > 1);
  if (conflictingEndpoints.isNotEmpty) {
    onViolation?.call();
    for (final conflict in conflictingEndpoints) {
      final originalFilePath = path.normalize(
        path.join('routes', conflict.value.first.path),
      );
      final conflictingFilePath = path.normalize(
        path.join('routes', conflict.value.last.path),
      );
      onRouteConflict(
        originalFilePath,
        conflictingFilePath,
        conflict.key,
      );
    }
    onExit?.call();
  }
}
