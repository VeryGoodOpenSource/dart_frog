import 'package:dart_frog_cli/src/daemon/daemon.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _TestDomain extends Domain {
  @override
  Future<void> dispose() async {}

  @override
  String get domainName => 'test';
}

class _MockDaemonServer extends Mock implements DaemonServer {}

void main() {
  group('$Domain', () {
    Future<DaemonResponse> myHandler(DaemonRequest request) async {
      return DaemonResponse.success(
        id: request.id,
        result: {
          'foo': 'bar',
          if (request.params != null) ...request.params!,
        },
      );
    }

    test('routes requests to handlers', () async {
      final domain = _TestDomain()..addHandler('myHandler', myHandler);
      final response = await domain.handleRequest(
        const DaemonRequest(
          id: '1',
          method: 'myHandler',
          domain: 'test',
          params: {'baz': 'qux'},
        ),
      );

      expect(
        response,
        const DaemonResponse.success(
          id: '1',
          result: {'foo': 'bar', 'baz': 'qux'},
        ),
      );
    });

    test('handles invalid requests', () async {
      final domain = _TestDomain()..addHandler('myHandler', myHandler);
      final response = await domain.handleRequest(
        const DaemonRequest(
          id: '1',
          method: 'invalidHandler',
          domain: 'test',
        ),
      );

      expect(
        response,
        const DaemonResponse.error(
          id: '1',
          error: {'message': 'Method not found: invalidHandler'},
        ),
      );
    });
  });

  group('$DaemonDomain', () {
    late DaemonServer daemonServer;

    setUp(() {
      daemonServer = _MockDaemonServer();

      when(() => daemonServer.version).thenReturn('1.0.0');
    });

    test('can be instantiated', () async {
      expect(DaemonDomain(daemonServer), isNotNull);
    });

    test('emits initial event', () async {
      expect(
        DaemonDomain(
          daemonServer,
          processId: 42,
        ),
        isNotNull,
      );

      verify(
        () => daemonServer.sendEvent(
          const DaemonEvent(
            domain: 'daemon',
            event: 'ready',
            params: {
              'version': '1.0.0',
              'processId': 42,
            },
          ),
        ),
      ).called(1);
    });

    group('requestVersion', () {
      test('returns current version', () async {
        final domain = DaemonDomain(daemonServer, processId: 42);

        final response = await domain.handleRequest(
          const DaemonRequest(
            id: '12',
            domain: 'daemon',
            method: 'requestVersion',
          ),
        );

        expect(
          response,
          const DaemonResponse.success(
            id: '12',
            result: {'version': '1.0.0'},
          ),
        );
      });
    });

    group('kill', () {
      test('kills the daemon and sends goodbye', () async {
        final domain = DaemonDomain(daemonServer, processId: 42);

        when(() => daemonServer.kill(ExitCode.success))
            .thenAnswer((_) async {});

        final response = await domain.handleRequest(
          const DaemonRequest(
            id: '12',
            domain: 'daemon',
            method: 'kill',
          ),
        );

        verify(() => daemonServer.kill(ExitCode.success)).called(1);

        expect(
          response,
          const DaemonResponse.success(
            id: '12',
            result: {
              'message': 'Hogarth. You stay, I go. No following.',
            },
          ),
        );
      });
    });
  });
}
