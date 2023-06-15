import 'dart:async';
import 'dart:io';

import 'package:dart_frog_cli/src/daemon/daemon.dart';
import 'package:dart_frog_cli/src/daemon/protocol.dart';
import 'package:mason/mason.dart';
import 'package:uuid/uuid.dart';

export 'application.dart';
export 'route_config.dart';

typedef DomaonRequestHandler = Future<DaemonResponse> Function(
  DaemonRequest request,
);

abstract class Domain {
  Domain(this.daemon);

  static const Uuid _uuidGenerator = Uuid();

  final Daemon daemon;

  String get name;

  final Map<String, DomaonRequestHandler> _handlers = {};

  final String Function() getId = () => _uuidGenerator.v4();

  void addHandler(String method, DomaonRequestHandler handler) {
    _handlers[method] = handler;
  }

  void handleRequest(DaemonRequest request) async {
    final handler = _handlers[request.method.split('.').last];
    if (handler != null) {
      final response = await handler(request);
      daemon.send(response);
    }
  }
}

class DaemonDomain extends Domain {
  DaemonDomain(super.daemon) {
    addHandler('kill', kill);
    addHandler('requestVersion', requestVersion);

    daemon.send(
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

  Future<DaemonResponse> kill(DaemonRequest request) async {
   scheduleMicrotask(() {
     daemon.kill(ExitCode.success);
   });
    return DaemonResponse.success(id: request.id, result: {
      'message': 'Hogarth. You stay, I go. No following.',
    });
  }

  Future<DaemonResponse> requestVersion(DaemonRequest request) async {
    return DaemonResponse.success(
      id: request.id,
      result: {
        'version': daemon.version,
      },
    );
  }
}
