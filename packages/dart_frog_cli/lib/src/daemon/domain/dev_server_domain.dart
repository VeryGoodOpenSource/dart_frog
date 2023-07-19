import 'package:dart_frog_cli/src/daemon/daemon.dart';
import 'package:dart_frog_cli/src/dev_server_runner/dev_server_runner.dart';

class DevServerDomain extends DomainBase {
  DevServerDomain() {
    addHandler('start', _start);
  }

  @override
  String get domainName => 'devserver';

  final _devServerRunenrs = <String, DevServerRunner>{};

  Future<DaemonResponse> _start(DaemonRequest request) async {
    final workingDirectory = request.params?['workingDirectory'];
    if (workingDirectory is! String) {
      throw const DartFrogDaemonMalformedMessageException(
        'invalid workingDirectory',
      );
    }

    final rawPort = request.params?['port'];
    if (rawPort is! int?) {
      throw const DartFrogDaemonMalformedMessageException('invalid port');
    }

    final dartVmServicePort = request.params?['dartVmServicePort'];
    if (dartVmServicePort is! String?) {
      throw const DartFrogDaemonMalformedMessageException(
        'invalid dartVmServicePort',
      );
    }
  }

  @override
  Future<void> dispose() async {}
}
