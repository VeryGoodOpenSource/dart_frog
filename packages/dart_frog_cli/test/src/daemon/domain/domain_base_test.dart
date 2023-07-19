import 'package:dart_frog_cli/src/daemon/daemon.dart';
import 'package:test/test.dart';

class _TestDomain extends DomainBase {
  @override
  Future<void> dispose() async {}

  @override
  String get domainName => 'test';
}

void main() {
  group('$DomainBase', () {
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
}
