import 'package:dart_frog_new_hooks/src/route_to_path.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('routeToPath', () {
    test('defaults to current platform path context', () {
      expect(routeToPath('/'), equals(path.join('routes', 'index.dart')));
    });
  });

  group('routeToPath posix', () {
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
            equals(path.posix.normalize(entry.value)),
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
            equals(path.posix.normalize(entry.value)),
          );
        });
      }
    });
  });

  group('routeToPath windows', () {
    group('preferIndex false', () {
      final expectedRouteToPathMappings = <String, String>{
        '/': r'..\routes\index.dart',
        '/hello': r'..\routes\hello.dart',
        '/hello/world': r'..\routes\hello\world.dart',
        '/hello/[name]': r'..\routes\hello\[name].dart',
        '/[id]/item': r'..\routes\[id]\item.dart',
        '/[id]/part/item': r'..\routes\[id]\part\item.dart',
      };

      for (final entry in expectedRouteToPathMappings.entries) {
        test('maps ${entry.key} -> ${entry.value}', () {
          expect(
            routeToPath(
              entry.key,
              preamble: r'..\routes',
              pathContext: path.windows,
            ),
            equals(path.windows.normalize(entry.value)),
          );
        });
      }
    });

    group('preferIndex true', () {
      final expectedRouteToPathMappings = <String, String>{
        '/': r'..\routes\index.dart',
        '/hello': r'..\routes\hello\index.dart',
        '/hello/world': r'..\routes\hello\world\index.dart',
        '/hello/[name]': r'..\routes\hello\[name]\index.dart',
        '/[id]/item': r'..\routes\[id]\item\index.dart',
        '/[id]/part/item': r'..\routes\[id]\part\item\index.dart',
      };

      for (final entry in expectedRouteToPathMappings.entries) {
        test('maps ${entry.key} -> ${entry.value}', () {
          expect(
            routeToPath(
              entry.key,
              preferIndex: true,
              preamble: r'..\routes',
              pathContext: path.windows,
            ),
            equals(path.windows.normalize(entry.value)),
          );
        });
      }
    });
  });
}
