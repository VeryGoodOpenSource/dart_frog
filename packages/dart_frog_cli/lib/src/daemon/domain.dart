import 'dart:async';
import 'dart:io';

import 'package:dart_frog_cli/src/daemon/daemon.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';

/// Type definition for a daemon method which handles a [DaemonRequest].
typedef DomainRequestHandler = Future<DaemonResponse> Function(
  DaemonRequest request,
);

/// {@template domain}
/// A domain is a collection of methods that are semantically associated.
/// {@endtemplate}
abstract class Domain {
  final Map<String, DomainRequestHandler> _handlers = {};

  /// The name of this domain.
  String get domainName;

  /// Adds a [handler] for a [method].
  ///
  /// Should be called in the constructor of a subclass.
  @protected
  @visibleForTesting
  void addHandler(String method, DomainRequestHandler handler) {
    assert(!_handlers.containsKey(method), 'Duplicate handler for $method');
    _handlers[method] = handler;
  }

  /// Handles a [DaemonRequest] and sends the response to the client.
  @nonVirtual
  Future<DaemonResponse> handleRequest(DaemonRequest request) async {
    final handler = _handlers[request.method];
    if (handler == null) {
      return DaemonResponse.error(
        id: request.id,
        error: {
          'message': 'Method not found: ${request.method}',
        },
      );
    }
    return handler(request);
  }

  /// Disposes of this domain.
  Future<void> dispose();
}

/// {@template daemon_domain}
/// The daemon domain.
///
/// This should include all the meta-related methods.
/// {@endtemplate}
class DaemonDomain extends Domain {
  /// {@macro daemon_domain}
  DaemonDomain(
    this.daemon, {
    @visibleForTesting int? processId,
  }) {
    addHandler('requestVersion', _requestVersion);
    addHandler('kill', _kill);

    daemon.sendEvent(
      DaemonEvent(
        domain: domainName,
        event: 'ready',
        params: {
          'version': daemon.version,
          'processId': processId ?? pid,
        },
      ),
    );
  }

  /// The name of this domain.
  static const String name = 'daemon';

  /// The [DaemonServer] instance used by this domain.
  final DaemonServer daemon;

  @override
  String get domainName => name;

  /// Requests the version of the daemon.
  Future<DaemonResponse> _requestVersion(DaemonRequest request) async {
    return DaemonResponse.success(
      id: request.id,
      result: {
        'version': daemon.version,
      },
    );
  }

  /// Kills the daemon.
  Future<DaemonResponse> _kill(DaemonRequest request) async {
    daemon.kill(ExitCode.success).ignore();
    return DaemonResponse.success(
      id: request.id,
      result: const {
        'message': 'Hogarth. You stay, I go. No following.',
      },
    );
  }

  @override
  Future<void> dispose() async {}
}
