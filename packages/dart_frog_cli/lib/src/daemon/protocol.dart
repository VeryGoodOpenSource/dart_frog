// ignore_for_file: public_member_api_docs

import 'package:meta/meta.dart';

sealed class DaemonMessage {
  DaemonMessage();

  factory DaemonMessage.fromJson(dynamic json) {
    json as List<dynamic>;
    final rawMessage = json.first;
    if (rawMessage is Map<String, dynamic>) {
      if (rawMessage.containsKey('method')) {
        return DaemonRequest.fromJson(rawMessage);
      } else if (rawMessage.containsKey('result')) {
        return DaemonResponse.fromJson(rawMessage);
      } else if (rawMessage.containsKey('event')) {
        return DaemonEvent.fromJson(rawMessage);
      }
    }

    throw StateError('Invalid Json');
  }

  Map<String, dynamic> toJson();
}

class DaemonRequest extends DaemonMessage {
  DaemonRequest({
    required this.id,
    required this.method,
    required this.params,
  });

  factory DaemonRequest.fromJson(Map<String, dynamic> rawMessage) {
    return DaemonRequest(
      id: rawMessage['id'] as String,
      method: rawMessage['method'] as String,
      params: rawMessage['params'] as Map<String, dynamic>,
    );
  }

  final String id;
  final String method;
  final Map<String, dynamic> params;

  @override
  @nonVirtual
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method': method,
      'params': params,
    };
  }
}

class DaemonResponse extends DaemonMessage {
  DaemonResponse._({
    required this.id,
    required this.result,
    required this.error,
  });

  DaemonResponse.success({
    required String id,
    required Map<String, dynamic> result,
  }) : this._(id: id, result: result, error: null);

  DaemonResponse.error({
    required String id,
    required Map<String, dynamic> error,
  }) : this._(id: id, result: null, error: error);

  factory DaemonResponse.fromJson(Map<String, dynamic> rawMessage) {
    return DaemonResponse._(
      id: rawMessage['id'] as String,
      result: rawMessage['result'] as Map<String, dynamic>?,
      error: rawMessage['error'] as Map<String, dynamic>?,
    );
  }

  final String id;
  final Map<String, dynamic>? result;
  final Map<String, dynamic>? error;

  @override
  @nonVirtual
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (result != null) 'result': result,
      if (error != null) 'error': error,
    };
  }
}

class DaemonEvent extends DaemonMessage {
  DaemonEvent({
    required this.domain,
    required this.event,
    required this.params,
  });

  factory DaemonEvent.fromJson(Map<String, dynamic> rawMessage) {
    return DaemonEvent(
      domain: rawMessage['domain'] as String,
      event: rawMessage['event'] as String,
      params: rawMessage['params'] as Map<String, dynamic>,
    );
  }

  final String event;

  final String domain;

  final Map<String, dynamic> params;

  @override
  Map<String, dynamic> toJson() {
    return {
      'event': '$domain.$event',
      'params': params,
    };
  }
}
