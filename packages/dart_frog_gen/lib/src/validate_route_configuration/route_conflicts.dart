import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:path/path.dart' as path;

/// Type definition for callbacks that report route conflicts.
typedef OnRouteConflict = void Function(
  String originalFilePath,
  String conflictingFilePath,
  String conflictingEndpoint,
);

/// Reports existence of route conflicts on a [RouteConfiguration].
void reportRouteConflicts(
  RouteConfiguration configuration, {
  /// Callback called when any route conflict is found.
  void Function()? onViolationStart,

  /// Callback called for each route conflict found.
  OnRouteConflict? onRouteConflict,

  /// Callback called when any route conflict is found.
  void Function()? onViolationEnd,
}) {
  final directConflicts =
      configuration.endpoints.entries.where((entry) => entry.value.length > 1);

  final indirectConflicts = configuration.endpoints.entries.where((entry) {
    final match = configuration.endpoints.keys.where((other) {
      final keyParts = entry.key.split('/');
      if (other == entry.key) {
        return false;
      }

      final otherParts = other.split('/');

      var match = false;

      if (keyParts.length == otherParts.length) {
        for (var i = 0; i < keyParts.length; i++) {
          if ((keyParts[i] == otherParts[i]) ||
              (keyParts[i].startsWith('<') || otherParts[i].startsWith('<'))) {
            match = true;
          } else {
            match = false;
            break;
          }
        }
      }

      return match;
    }).isNotEmpty;

    return match;
  });

  final conflictingEndpoints = [...directConflicts, ...indirectConflicts];

  if (conflictingEndpoints.isNotEmpty) {
    onViolationStart?.call();
    for (final conflict in conflictingEndpoints) {
      final originalFilePath = path.normalize(
        path.join('routes', conflict.value.first.path),
      );
      final conflictingFilePath = path.normalize(
        path.join('routes', conflict.value.last.path),
      );
      onRouteConflict?.call(
        originalFilePath,
        conflictingFilePath,
        conflict.key,
      );
    }
    onViolationEnd?.call();
  }
}
