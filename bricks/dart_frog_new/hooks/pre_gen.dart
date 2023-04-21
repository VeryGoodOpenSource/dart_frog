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

  final routePathRaw = context.vars['route_path'] as String;

  final routePath = routePathRaw.normalizedRoutePath;

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
      routePath: routePath,
      configuration: configuration,
      projectDirectory: projectDirectory,
    );
  }
  return _preGenMiddleware(
    context,
    buildConfiguration: buildConfiguration,
    routePath: routePath,
    configuration: configuration,
    projectDirectory: projectDirectory,
  );
}

Future<void> _preGenRoute(
  HookContext context, {
  required RouteConfigurationBuilder buildConfiguration,
  required String routePath,
  required RouteConfiguration configuration,
  required io.Directory projectDirectory,
}) async {
  final routesDirectoryPath = p.relative(
    io.Directory(p.join(projectDirectory.path, 'routes')).path,
  );

  // verify if the endpoint does already exist
  final endpointExists = configuration.endpoints.containsKey(routePath);

  if (endpointExists) {
    context.logger.err('Failed to create route: $routePath already exists.');
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
        routePath,
        preamble: routesDirectoryPath,
      ).bracketParameterSyntax,
    ),
  ).existsSync();

  // if the route does not exist as directory, we must check if any of its
  // ancestor routes exists as file routes to avoid rogues
  if (!existsAsDirectory) {
    final containingFileRoute = configuration.checkForContainingFileRoute(
      routePath,
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

      context.logger.detail(
        'Renamed $filepath to $newFilepath to avoid rogue routes',
      );
    }
  }

  final routeFileName = routeToPath(
    routePath,
    preferIndex: existsAsDirectory,
    preamble: routesDirectoryPath,
  ).bracketParameterSyntax;

  context.logger.detail('Creating route file: $routeFileName');

  context.vars['dirname'] = p.dirname(routeFileName);
  context.vars['filename'] = p.basename(routeFileName);
  context.vars['params'] = routeFileName.bracketParameters;
}

Future<void> _preGenMiddleware(
  HookContext context, {
  required RouteConfigurationBuilder buildConfiguration,
  required String routePath,
  required RouteConfiguration configuration,
  required io.Directory projectDirectory,
}) async {
  final routesDirectoryPath = p.relative(
    io.Directory(p.join(projectDirectory.path, 'routes')).path,
  );

  const middlewareFilename = '_middleware.dart';

  final String middlewareContainingDir;
  if (routePath == '/') {
    middlewareContainingDir = routesDirectoryPath;
  } else {
    middlewareContainingDir = p.withoutExtension(
      routeToPath(
        routePath,
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

    return middlewareFilePath == existingMiddlewareFilePath;
  });

  if (middlewareExists) {
    context.logger.err(
      'Failed to create middleware: $middlewareFilePath already exists',
    );
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
      routePath,
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

      context.logger.detail(
        'Renamed $filepath to $newFilepath to avoid rogue routes',
      );
    }
  }

  context.logger.detail(
    'Creating middleware file: ${middlewareFilePath.bracketParameterSyntax}',
  );

  context.vars['dirname'] = middlewareContainingDir.bracketParameterSyntax;
  context.vars['filename'] = middlewareFilename;
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
  String get normalizedRoutePath {
    final replaced = diamondParameterSyntax.replaceAll(r'\', '/');

    final segments = replaced.split('/');

    final normalizedSegments =
        segments.fold(<String>[''], (previousValue, segment) {
      if (segment == '..') {
        if (previousValue.length > 2) {
          previousValue.removeLast();
        }
      } else if (segment.isNotEmpty && segment != '.') {
        previousValue.add(segment.encodeSegment());
      }
      return previousValue;
    });

    return normalizedSegments.join('/');
  }

  String encodeSegment() {
    final encoded = Uri.encodeComponent(this);
    if (isDiamondParameterSegment) {
      return encoded.replaceAll('%3C', '<').replaceAll('%3E', '>');
    }
    return encoded;
  }

  /// detects if the given string has a < and a > after it
  bool get isDiamondParameterSegment {
    final regexp = RegExp('<.*?>');
    return regexp.hasMatch(this);
  }

  // replaces [] for <>
  String get diamondParameterSyntax =>
      replaceAll('[', '<').replaceAll(']', '>');

  // replaces <> for []
  String get bracketParameterSyntax =>
      replaceAll('<', '[').replaceAll('>', ']');

  List<String?> get bracketParameters {
    final regexp = RegExp(r'\[(.*?)\]');
    final matches = regexp.allMatches(bracketParameterSyntax);
    return matches
        .map((m) => m[0]?.replaceAll(RegExp(r'[\[\]]'), ''))
        .where((el) => el != null)
        .toList();
  }
}
