// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:dart_frog_cli/src/daemon/protocol.dart';
import 'package:mason/mason.dart';
import 'package:uuid/uuid.dart';

import '../daemon.dart';

abstract class Domain {
  Domain(this.daemon);

  static const Uuid _uuidGenerator = Uuid();

  final Daemon daemon;

  String get name;

  final Map<String, Function> handlers = {};

  final String Function() getId = () => _uuidGenerator.v4();

  void addHandler(String method, Function handler) {
    handlers[method] = handler;
  }

  void handleRequest(DaemonRequest request) {
    final handler = handlers[request.method.split('.').last];
    if (handler != null) {
      handler(request);
    }
    // todo: handle unkown method
  }
}

class DaemonDomain extends Domain {
  DaemonDomain(super.daemon) {
    addHandler('kill', kill);
    addHandler('requestVersion', requestVersion);

    daemon.conenction.send(
      DaemonEvent(
        domain: name,
        event: 'ready',
        params: {
          'version': daemon.version,
          'processId': pid,
        },
      ),
    );
  }

  @override
  String get name => 'daemon';

  void kill(DaemonRequest request) {
    daemon.kill(ExitCode.success);
  }

  void requestVersion(DaemonRequest request) {
    daemon.conenction.send(
      DaemonResponse.success(
        id: request.id,
        result: {
          'version': daemon.version,
        },
      ),
    );
  }
}


final oi = [{"method": "application.run", "params": {"port": "9090"}, "id": "1" }];