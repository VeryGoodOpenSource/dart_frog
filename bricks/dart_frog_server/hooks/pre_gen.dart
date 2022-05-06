import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart' show pathToRoute;
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

Future<void> run(HookContext context) async {
  final routesDirectory =
      Directory(path.join(Directory.current.path, 'routes'));

  if (!routesDirectory.existsSync()) {
    context.logger.err('Could not find directory ${routesDirectory.path}');
    exit(1);
  }

  final directories = <RouteDirectory>[
    RouteDirectory(
      name: 'd1',
      path: '/',
      middleware: false,
      files: [
        RouteFile(
          name: 'r1',
          path: './routes/index.dart',
          route: '/',
        ),
        RouteFile(
          name: 'r2',
          path: './routes/hello.dart',
          route: '/hello',
        )
      ],
    ),
    RouteDirectory(
      name: 'd2',
      path: '/api',
      middleware: true,
      files: [],
    ),
    RouteDirectory(
      name: 'd3',
      path: '/api/v1',
      middleware: false,
      files: [
        RouteFile(
          name: 'r3',
          path: './routes/api/v1/index.dart',
          route: '/',
        )
      ],
    )
  ];
  final routes = <RouteFile>[
    RouteFile(
      name: 'r1',
      path: './routes/index.dart',
      route: '/',
    ),
    RouteFile(
      name: 'r2',
      path: './routes/hello.dart',
      route: '/hello',
    ),
    RouteFile(
      name: 'r3',
      path: './routes/api/v1/index.dart',
      route: '/api/v1',
    )
  ];

  context.vars = {
    'directories': directories.map((c) => c.toJson()).toList(),
    'routes': routes.map((r) => r.toJson()).toList(),
  };
}

// RouteDirectory buildConfiguration(
//   Directory directory, {
//   void Function(RouteFile route)? onRoute,
//   int depth = 0,
// }) {
//   final configuration = RouteDirectory(
//     name: '/${path.basenameWithoutExtension(path.relative(directory.path))}',
//     middleware:
//         File(path.join(directory.path, '_middleware.dart')).existsSync(),
//     files: [],
//     directories: [],
//   );

//   directory.listSync().forEach(
//     (entity) {
//       if (entity.isRoute) {
//         depth++;
//         final filePath = path.join(
//           '..',
//           path.relative(entity.path).replaceAll(r'\', '/'),
//         );
//         final fileRoute = pathToRoute(filePath).split(configuration.name).last;
//         final route = RouteFile(
//           name: 'r$depth',
//           path: filePath,
//           route: fileRoute.isEmpty ? '/' : fileRoute,
//         );
//         onRoute?.call(route);
//         configuration.files.add(route);
//       } else if (entity is Directory) {
//         configuration.directories.add(buildConfiguration(
//           entity,
//           onRoute: onRoute,
//           depth: depth,
//         ));
//       }
//     },
//   );

//   return configuration;
// }

extension on FileSystemEntity {
  bool get isRoute {
    return this is File &&
        path.basename(this.path).endsWith('.dart') &&
        !this.isMiddleware;
  }

  bool get isMiddleware {
    return this is File && path.basename(this.path) == '_middleware.dart';
  }
}

class RouteDirectory {
  const RouteDirectory({
    required this.name,
    required this.path,
    required this.middleware,
    required this.files,
  });

  final String name;
  final String path;
  final bool middleware;
  final List<RouteFile> files;

  RouteDirectory copyWith({
    String? name,
    String? path,
    bool? middleware,
    List<RouteFile>? files,
  }) {
    return RouteDirectory(
      name: name ?? this.name,
      path: path ?? this.path,
      middleware: middleware ?? this.middleware,
      files: files ?? this.files,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'path': path,
      'middleware': middleware,
      'files': files.map((f) => f.toJson()).toList(),
    };
  }
}

class RouteFile {
  const RouteFile({
    required this.name,
    required this.path,
    required this.route,
  });

  final String name;
  final String path;
  final String route;

  RouteFile copyWith({String? name, String? path, String? route}) {
    return RouteFile(
      name: name ?? this.name,
      path: path ?? this.path,
      route: route ?? this.route,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'path': path,
      'route': route,
    };
  }
}
