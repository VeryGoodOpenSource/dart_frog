import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:dart_frog_new_hooks/src/route_configuration_utils.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockRouteConfiguration extends Mock implements RouteConfiguration {}

void main() {
  group('RouteConfigurationUtils', () {
    group('validate', () {
      late RouteConfiguration configuration;

      setUp(() {
        configuration = _MockRouteConfiguration();
        when(() => configuration.rogueRoutes).thenReturn([]);
        when(() => configuration.endpoints).thenReturn({});
      });

      test('reports rogue route', () {
        when(() => configuration.rogueRoutes).thenReturn(
          const [
            RouteFile(
              name: 'hello',
              path: 'hello.dart',
              route: '/hello',
              params: [],
              wildcard: false,
            ),
          ],
        );

        expect(
          () => configuration.validate(),
          throwsA(
            isA<FormatException>().having(
              (p) => p.message,
              'error message',
              '''Rogue route detected.${defaultForeground.wrap(' ')}Rename ${lightCyan.wrap('routes/hello.dart')} to ${lightCyan.wrap('routes/hello/index.dart')}.''',
            ),
          ),
        );
      });

      test('report route conflict', () {
        when(() => configuration.endpoints).thenReturn({
          '/': const [
            RouteFile(
              name: 'index',
              path: 'index.dart',
              route: '/',
              params: [],
              wildcard: false,
            ),
          ],
          '/hello': const [
            RouteFile(
              name: 'hello',
              path: 'hello.dart',
              route: '/hello',
              params: [],
              wildcard: false,
            ),
            RouteFile(
              name: 'hello_index',
              path: 'hello/index.dart',
              route: '/',
              params: [],
              wildcard: false,
            )
          ]
        });

        expect(
          () => configuration.validate(),
          throwsA(
            isA<FormatException>().having(
              (p) => p.message,
              'error message',
              '''Route conflict detected. ${lightCyan.wrap('routes/hello.dart')} and ${lightCyan.wrap('routes/hello/index.dart')} both resolve to ${lightCyan.wrap('/hello')}.''',
            ),
          ),
        );
      });
    });

    group('containingFileRoute', () {
      late RouteConfiguration configuration;
      setUp(() {
        configuration = _MockRouteConfiguration();
        when(() => configuration.endpoints).thenReturn({
          '/': const <RouteFile>[
            RouteFile(
              name: 'index',
              path: '../routes/index.dart',
              route: '/',
              params: [],
              wildcard: false,
            )
          ],
          '/<id>': const <RouteFile>[
            RouteFile(
              name: r'$id_index',
              path: '../routes/[id]/index.dart',
              route: '/',
              params: [],
              wildcard: false,
            )
          ],
          '/<id>/existing_as_file': const <RouteFile>[
            RouteFile(
              name: r'$id_existing_as_file',
              path: '../routes/[id]/existing_as_file.dart',
              route: '/existing_as_file',
              params: [],
              wildcard: false,
            )
          ],
          '/<id>/existing_as_dir': const <RouteFile>[
            RouteFile(
              name: r'$id_existing_as_dir_index',
              path: '../routes/[id]/existing_as_dir/index.dart',
              route: '/',
              params: [],
              wildcard: false,
            )
          ],
        });
      });

      group('includeSelf false', () {
        test('returns null for the root route', () {
          final result = configuration.containingFileRoute('/');

          expect(result, isNull);
        });

        test('returns null for routes with no file route as ancestor', () {
          final result = configuration.containingFileRoute(
            '/<id>/existing_as_dir/new_route',
          );

          expect(result, isNull);
        });

        test('returns the innermost file route', () {
          final result = configuration.containingFileRoute(
            '/<id>/existing_as_file/new_route',
          );

          expect(
            result,
            const RouteFile(
              name: r'$id_existing_as_file',
              path: '../routes/[id]/existing_as_file.dart',
              route: '/existing_as_file',
              params: [],
              wildcard: false,
            ),
          );
        });

        test('returns null when the given route is a file route', () {
          final result = configuration.containingFileRoute(
            '/<id>/existing_as_dir',
          );

          expect(result, isNull);
        });
      });

      group('includeSelf true', () {
        test('returns null for the root route', () {
          final result = configuration.containingFileRoute(
            '/',
            includeSelf: true,
          );

          expect(result, isNull);
        });

        test('returns null for routes with no file route as ancestor', () {
          final result = configuration.containingFileRoute(
            '/<id>/existing_as_dir/new_route',
            includeSelf: true,
          );

          expect(result, isNull);
        });

        test('returns the innermost file route', () {
          final result = configuration.containingFileRoute(
            '/<id>/existing_as_file/new_route',
            includeSelf: true,
          );

          expect(
            result,
            const RouteFile(
              name: r'$id_existing_as_file',
              path: '../routes/[id]/existing_as_file.dart',
              route: '/existing_as_file',
              params: [],
              wildcard: false,
            ),
          );
        });

        test('returns the given route when that is a file route', () {
          final result = configuration.containingFileRoute(
            '/<id>/existing_as_file',
            includeSelf: true,
          );

          expect(
            result,
            const RouteFile(
              name: r'$id_existing_as_file',
              path: '../routes/[id]/existing_as_file.dart',
              route: '/existing_as_file',
              params: [],
              wildcard: false,
            ),
          );
        });
      });
    });
  });
}
