import 'package:dart_frog_gen/src/path_to_route.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('pathToRoute', () {
    final expectedPathToRouteMappings = <String, String>{
      '../routes/index.dart': '/',
      '../routes/hello.dart': '/hello',
      '../routes/hello/world.dart': '/hello/world',
      '../routes/hello/[name].dart': '/hello/[name]',
      '../routes/[id]/item.dart': '/[id]/item',
      '../routes/[id]/part/item.dart': '/[id]/part/item',
      '../routes/[id]/part/index.dart': '/[id]/part',
      '../routes/api/v1/index.dart': '/api/v1',
      r'..\routes\index.dart': '/',
      r'..\routes\hello.dart': '/hello',
      r'..\routes\hello\world.dart': '/hello/world',
      r'..\routes\hello\[name].dart': '/hello/[name]',
      r'..\routes\api\v1\index.dart': '/api/v1',
    };

    for (final entry in expectedPathToRouteMappings.entries) {
      test('maps ${entry.key} -> ${entry.value}', () {
        expect(pathToRoute(entry.key), equals(entry.value));
      });
    }
  });

  group('routeToPath', () {
    group('preferIndex false', () {
      final expectedRouteToPathMappings = <String, String>{
        '/': '../routes/index.dart',
        '/hello': '../routes/hello.dart',
        '/hello/world': '../routes/hello/world.dart',
        '/hello/[name]': '../routes/hello/[name].dart',
        '/[id]/item': '../routes/[id]/item.dart',
        '/[id]/part/item': '../routes/[id]/part/item.dart',
      };

      for (final entry in expectedRouteToPathMappings.entries) {
        test('maps ${entry.key} -> ${entry.value}', () {
          expect(
            routeToPath(entry.key, preamble: '../routes'),
            equals(p.posix.normalize(entry.value)),
          );
        });
      }
    });

    group('preferIndex true', () {
      final expectedRouteToPathMappings = <String, String>{
        '/': '../routes/index.dart',
        '/hello': '../routes/hello/index.dart',
        '/hello/world': '../routes/hello/world/index.dart',
        '/hello/[name]': '../routes/hello/[name]/index.dart',
        '/[id]/item': '../routes/[id]/item/index.dart',
        '/[id]/part/item': '../routes/[id]/part/item/index.dart',
      };

      for (final entry in expectedRouteToPathMappings.entries) {
        test('maps ${entry.key} -> ${entry.value}', () {
          expect(
            routeToPath(entry.key, preferIndex: true, preamble: '../routes'),
            equals(p.posix.normalize(entry.value)),
          );
        });
      }
    });
  });
}
