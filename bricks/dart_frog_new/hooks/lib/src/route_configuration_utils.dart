import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason/mason.dart';

extension RouteConfigurationUtils on RouteConfiguration {
  /// Report rogue routes and route conflicts.
  void validate() {
    reportRogueRoutes(
      this,
      onRogueRoute: (filePath, idealPath) {
        throw FormatException(
          '''Rogue route detected.${defaultForeground.wrap(' ')}Rename ${lightCyan.wrap(filePath)} to ${lightCyan.wrap(idealPath)}.''',
        );
      },
    );

    reportRouteConflicts(
      this,
      onRouteConflict: (
        String originalFilePath,
        String conflictingFilePath,
        String conflictingEndpoint,
      ) {
        throw FormatException(
          '''Route conflict detected. ${lightCyan.wrap(originalFilePath)} and ${lightCyan.wrap(conflictingFilePath)} both resolve to ${lightCyan.wrap(conflictingEndpoint)}.''',
        );
      },
    );
  }

  /// Check if the ancestors of a route exists as file routes.
  /// Return the innermost route that exists as file route if any.
  ///
  /// On Dart Frog, file routes are routes defined by a file that has the last
  /// segment of the resulting URI as its name, as opposed to directory
  /// routes that are represented by an index file.
  ///
  /// This assumes that the route configuration has been validated against rogue
  /// routes and route conflicts.
  ///
  /// It also assumes that the [route] is normalized to use the same parameter
  /// syntax as used internally by [RouteConfiguration].
  RouteFile? containingFileRoute(
    String route, {
    bool includeSelf = false,
  }) {
    final segments = route.split('/');
    final containingRoutes = segments
        .map((segment) {
          return segments.takeWhile((element) => element != segment).join('/');
        })
        .where((route) => route.isNotEmpty)
        .toList();

    if (includeSelf) {
      containingRoutes.add(route);
    }

    for (final containingRoute in containingRoutes.reversed) {
      if (!endpoints.containsKey(containingRoute)) {
        continue;
      }

      final routeFile = endpoints[containingRoute]!.first;

      // HEURISTIC: index routes have paths to the route file,
      // which named 'index.dart'
      final isIndexRoute = routeFile.path.endsWith('index.dart');

      // If the route is an index route, there wont be file routes on the
      // upper level, assuming that there is no rogue routes on
      // the configuration.
      if (isIndexRoute) {
        return null;
      }
      return routeFile;
    }
    return null;
  }
}
