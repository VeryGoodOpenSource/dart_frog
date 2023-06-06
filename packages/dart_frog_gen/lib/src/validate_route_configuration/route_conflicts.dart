import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:path/path.dart' as path;

class _RouteConflict {
  const _RouteConflict(
    this.originalFilePath,
    this.conflictingFilePath,
    this.conflictingEndpoint,
  );

  final String originalFilePath;
  final String conflictingFilePath;
  final String conflictingEndpoint;
}

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
  final directConflicts = configuration.endpoints.entries
      .where((entry) => entry.value.length > 1)
      .map((e) => _RouteConflict(e.value.first.path, e.value.last.path, e.key));

  final indirectConflicts = configuration.endpoints.entries.map((entry) {
    final matches = configuration.endpoints.keys.where((other) {
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
    });

    if (matches.isNotEmpty) {
      return _RouteConflict(entry.key, matches.first, entry.key);
    }

    return null;
  }).whereType<_RouteConflict>();

  final conflictingEndpoints = [...directConflicts, ...indirectConflicts];

  if (conflictingEndpoints.isNotEmpty) {
    onViolationStart?.call();
    for (final conflict in conflictingEndpoints) {
      final originalFilePath = path.normalize(
        path.join('routes', conflict.originalFilePath),
      );
      final conflictingFilePath = path.normalize(
        path.join('routes', conflict.conflictingFilePath),
      );
      onRouteConflict?.call(
        originalFilePath,
        conflictingFilePath,
        conflict.conflictingEndpoint,
      );
    }
    onViolationEnd?.call();
  }
}
