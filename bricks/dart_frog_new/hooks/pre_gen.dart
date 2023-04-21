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
}) {
  final type = context.vars['type'] as String;

  final routeRaw = (context.vars['route'] as String).replaceAll(r'\', '/');

  final route = (routeRaw.startsWith('/') ? routeRaw : '/$routeRaw')
      .diamondParameterSyntax;

  final projectDirectory = directory ?? io.Directory.current;

  final RouteConfiguration configuration;
  try {
    configuration = buildConfiguration(projectDirectory);
  } catch (error) {
    context.logger.err('$error');
    io.exit(1);
  }

  final isRoute = type == 'route';

  context.vars['is_route'] = isRoute;

  if (isRoute) {
    return _preGenRoute(
      context,
      buildConfiguration: buildConfiguration,
      route: route,
      configuration: configuration,
      projectDirectory: projectDirectory,
    );
  }
  return _preGenMiddleware(
    context,
    buildConfiguration: buildConfiguration,
    route: route,
    configuration: configuration,
    projectDirectory: projectDirectory,
  );
}

Future<void> _preGenRoute(
  HookContext context, {
  required RouteConfigurationBuilder buildConfiguration,
  required String route,
  required RouteConfiguration configuration,
  required io.Directory projectDirectory,
}) async {
  final routesDirectoryPath = p.relative(
    io.Directory(p.join(projectDirectory.path, 'routes')).path,
  );

  // verify if the endpoint does already exist
  final endpointExists = configuration.endpoints.containsKey(route);

  if (endpointExists) {
    context.logger.err('Failed to create route: $route already exists.');
    io.exit(1);
  }

  // verify if current route configuratoin have conflicts
  try {
    configuration.validate();
  } on FormatException catch (error) {
    context.logger.err('Failed to create route: ${error.message}');
    io.exit(1);
  }

  // verify if the given route already exists as directory
  final existsAsDirectory = io.Directory(
    p.withoutExtension(
      routeToPath(
        route,
        preamble: routesDirectoryPath,
      ).bracketParameterSyntax,
    ),
  ).existsSync();

  // if the route does not exist as directory, we must check if any of its
  // ancestor routes exists as file routes to avoid rogues
  if (!existsAsDirectory) {
    final containingFileRoute = configuration.checkForContainingFileRoute(
      route,
    );
    if (containingFileRoute != null) {
      final filepath = p.normalize(
        p.join(
          routesDirectoryPath,
          containingFileRoute.path,
        ),
      );

      io.Directory(p.withoutExtension(filepath)).createSync();

      final newFilepath = filepath.replaceFirst('.dart', '/index.dart');

      io.File(filepath)
          .renameSync(filepath.replaceFirst('.dart', '/index.dart'));

      context.logger.info(
        'Renamed $filepath to $newFilepath to avoid rogue routes',
      );
    }
  }

  final routeFileName = routeToPath(
    route,
    preferIndex: existsAsDirectory,
    preamble: routesDirectoryPath,
  ).bracketParameterSyntax;

  context.logger.info('Creating route file: $routeFileName');

  context.vars['dirname'] = p.dirname(routeFileName);
  context.vars['filename'] = p.withoutExtension(p.basename(routeFileName));
  context.vars['params'] = routeFileName.parameters;
}

Future<void> _preGenMiddleware(
  HookContext context, {
  required RouteConfigurationBuilder buildConfiguration,
  required String route,
  required RouteConfiguration configuration,
  required io.Directory projectDirectory,
}) async {
  final routesDirectoryPath = p.relative(
    io.Directory(p.join(projectDirectory.path, 'routes')).path,
  );

  const middlewareFilename = '_middleware.dart';

  final String middlewareContainingDir;
  if (route == '/') {
    middlewareContainingDir = routesDirectoryPath;
  } else {
    middlewareContainingDir = p.withoutExtension(
      routeToPath(
        route,
        preamble: routesDirectoryPath,
      ),
    );
  }

  final middlewareFilePath = p.normalize(
    p.join(middlewareContainingDir, middlewareFilename),
  );

  // verify if middleware already exists
  final middlewareExists = configuration.middleware.any((middlewareFile) {
    final existingMiddlewareFilePath = p.normalize(
      p.join(
        routesDirectoryPath,
        middlewareFile.path,
      ),
    );

    context.logger
        .alert('$middlewareFilePath - e: $existingMiddlewareFilePath');

    return middlewareFilePath == existingMiddlewareFilePath;
  });

  if (middlewareExists) {
    context.logger.err('Failed to create middleware: '
        'middleware on $middlewareFilePath already exists');
    io.exit(1);
  }

  // verify if current route configuratoin have conflicts
  try {
    configuration.validate();
  } on FormatException catch (error) {
    context.logger.err('Failed to create middleware: ${error.message}');
    io.exit(1);
  }

  // verify if the given route already exists as directory
  final existsAsDirectory =
      io.Directory(middlewareContainingDir.bracketParameterSyntax).existsSync();

  // if the route does not exist as directory, we must check if any of its
  // ancestor routes exists as file routes to avoid rogues
  if (!existsAsDirectory) {
    final containingFileRoute = configuration.checkForContainingFileRoute(
      route,
      includeSelf: true,
    );
    if (containingFileRoute != null) {
      final filepath = p.normalize(
        p.join(
          routesDirectoryPath,
          containingFileRoute.path,
        ),
      );

      io.Directory(p.withoutExtension(filepath)).createSync();

      final newFilepath = filepath.replaceFirst('.dart', '/index.dart');

      io.File(filepath)
          .renameSync(filepath.replaceFirst('.dart', '/index.dart'));

      context.logger.info(
        'Renamed $filepath to $newFilepath to avoid rogue routes',
      );
    }
  }

  context.logger.info(
    'Creating middleware file: ${middlewareFilePath.bracketParameterSyntax}',
  );

  context.vars['dirname'] = middlewareContainingDir.bracketParameterSyntax;
  context.vars['filename'] =
      p.withoutExtension(middlewareFilename).bracketParameterSyntax;
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
  RouteFile? checkForContainingFileRoute(
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
      if (endpoints.containsKey(containingRoute)) {
        final routeFile = endpoints[containingRoute]!.first;
        final isDirectoryRoute = routeFile.path.endsWith('index.dart');
        if (isDirectoryRoute) {
          return null;
        }
        return routeFile;
      }
    }
    return null;
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
