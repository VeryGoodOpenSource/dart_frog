import 'dart:async';

import 'package:dart_frog_cli/src/daemon/daemon.dart';
import 'package:meta/meta.dart';

/// Type definition for a daemon method which handles a [DaemonRequest].
typedef DomainRequestHandler = Future<DaemonResponse> Function(
  DaemonRequest request,
);

/// {@template domain}
/// A domain is a collection of methods that are semantically associated.
/// {@endtemplate}
abstract class DomainBase {
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
    try {
      return await handleRequest(request);
    } on DartFrogDaemonException catch (e) {
      return DaemonResponse.error(
        id: request.id,
        error: {
          'message': e.message,
        },
      );
    }
  }

  /// Disposes of this domain.
  Future<void> dispose();
}
