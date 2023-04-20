import 'dart:io' as io;

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

typedef RouteConfigurationBuilder = RouteConfiguration Function(
  io.Directory directory,
);

Future<void> run(HookContext context) async => preGen(context);

Future<void> preGen(
  HookContext context, {
  io.Directory? directory,
  RouteConfigurationBuilder buildConfiguration = buildRouteConfiguration,
}) async {
  final route = (context.vars['route'] as String).replaceAll(r'\', '/');

  final routeNormalized =
      (route.startsWith('/') ? route : '/$route').diamondParameterSyntax;

  final projectDirectory = directory ?? io.Directory.current;
  final routesDirectory = io.Directory(p.join(projectDirectory.path, 'routes'));

  final RouteConfiguration configuration;
  try {
    configuration = buildConfiguration(projectDirectory);
  } catch (error) {
    context.logger.err('$error');
    io.exit(1);
  }

  // verify if the endpoint does already exist
  final endpointExists = configuration.endpoints.containsKey(routeNormalized);

  if (endpointExists) {
    context.logger
        .err('Failed to create route: $route already exists.');
    io.exit(1);
  }

  // verify if current route configuraiton have conflicts
  try {
    configuration.validate();
  } on FormatException catch (error) {
    context.logger.err('Failed to create route: ${error.message}');
    io.exit(1);
  }
  // verify if the given route already exists as directory
  final existsAsDirectory = configuration.directories.any(
    (element) => element.route == routeNormalized,
  );

  // if the route doesnt exist as directory, we must check if any of its
  // ancestor routes exists as file routes to avoid rogues
  if (!existsAsDirectory) {
    final containingFileRoute = configuration.checkForContainingFileRoute(
      routeNormalized,
    );
    if (containingFileRoute != null) {
      final filepath = p.normalize(p.join(
        routesDirectory.path,
        containingFileRoute.path,
      ));

      io.Directory(p.withoutExtension(filepath)).createSync();

      final newFilepath = filepath.replaceFirst('.dart', '/index.dart');

      io.File(filepath)
          .renameSync(filepath.replaceFirst('.dart', '/index.dart'));

      context.logger.info(
        'Renamed ${p.relative(filepath)} to ${p.relative(newFilepath)} to avoid rogue routes',
      );
    }
  }


  final routeFileName = routeToPath(
    routeNormalized,
    preferIndex: existsAsDirectory,
    preamble: p.relative(routesDirectory.path),
  ).bracketParameterSyntax;

  context.logger.info('Creating route file: $routeFileName');

  context.vars['dirname'] = p.dirname(routeFileName);
  context.vars['filename'] = p.withoutExtension(p.basename(routeFileName));
  context.vars['params'] = routeFileName.parameters;
}

extension on RouteConfiguration {
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
  RouteFile? checkForContainingFileRoute(String route) {
    final segments = route.split('/');
    final containingRoutes = segments
        .map((segment) {
          return segments.takeWhile((element) => element != segment).join('/');
        })
        .where((route) => route.isNotEmpty)
        .toList()
        .reversed;

    for (final containingRoute in containingRoutes) {
      if (endpoints.containsKey(containingRoute)) {
        final routeFile = endpoints[containingRoute]!.first;
        final isDirectoryRoute = routeFile.path.endsWith('index.dart');
        if (isDirectoryRoute) {
          return null;
        }
        return routeFile;
      }
    }
  }
}

extension on String {
  // replaces [] for <>
  String get diamondParameterSyntax =>
      replaceAll('[', '<').replaceAll(']', '>');

  // replaces <> for []
  String get bracketParameterSyntax =>
      replaceAll('<', '[').replaceAll('>', ']');

  List<String?> get parameters {
    final regexp = RegExp(r'\[(.*?)\]');
    final matches = regexp.allMatches(bracketParameterSyntax);
    return matches
        .map((m) => m[0]?.replaceAll(RegExp(r'[\[\]]'), ''))
        .where((el) => el != null)
        .toList();
  }
}
