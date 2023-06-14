// ignore_for_file: public_member_api_docs

import 'package:dart_frog_cli/src/daemon/domain/domain.dart';
import 'package:dart_frog_cli/src/daemon/protocol.dart';
import 'package:mason/mason.dart';

String? _dullStyle(String? m) => m;

const _dullLoggerTheme = LogTheme(
  detail: _dullStyle,
  info: _dullStyle,
  err: _dullStyle,
  warn: _dullStyle,
  alert: _dullStyle,
  success: _dullStyle,
);

class DaemonLogger implements Logger {
  DaemonLogger(this.domain, this.params);

  final Domain domain;

  final Map<String, dynamic> params;

  @override
  LogTheme get theme => _dullLoggerTheme;

  @override
  Level level = Level.info;

  @override
  ProgressOptions progressOptions = const ProgressOptions(
    animation: ProgressAnimation(frames: ['']),
  );

  @override
  void alert(String? message, {LogStyle? style}) {
    domain.daemon.conenction.send(
      DaemonEvent(
        domain: domain.name,
        event: 'loggerAlert',
        params: {
          ...params,
          'message': message ?? '',
        },
      ),
    );
  }

  @override
  List<T> chooseAny<T extends Object?>(
    String? message, {
    required List<T> choices,
    List<T>? defaultValues,
    String Function(T choice)? display,
  }) {
    throw UnimplementedError();
  }

  @override
  T chooseOne<T extends Object?>(
    String? message, {
    required List<T> choices,
    T? defaultValue,
    String Function(T choice)? display,
  }) {
    throw UnimplementedError();
  }

  @override
  bool confirm(String? message, {bool defaultValue = false}) {
    throw UnimplementedError();
  }

  @override
  void delayed(String? message) {
    throw UnimplementedError();
  }

  @override
  void detail(String? message, {LogStyle? style}) {
    domain.daemon.conenction.send(
      DaemonEvent(
        domain: domain.name,
        event: 'loggerDetail',
        params: {
          ...params,
          'message': message ?? '',
        },
      ),
    );
  }

  @override
  void err(String? message, {LogStyle? style}) {
    domain.daemon.conenction.send(
      DaemonEvent(
        domain: domain.name,
        event: 'loggerError',
        params: {
          ...params,
          'message': message ?? '',
        },
      ),
    );
  }

  @override
  void flush([void Function(String? p1)? print]) {
    throw UnimplementedError();
  }

  @override
  void info(String? message, {LogStyle? style}) {
    domain.daemon.conenction.send(
      DaemonEvent(
        domain: domain.name,
        event: 'loggerInfo',
        params: {
          ...params,
          'message': message ?? '',
        },
      ),
    );
  }

  @override
  Progress progress(String message, {ProgressOptions? options}) {
    return LoggerDomainProgress(
      domain: domain.name,
      message: message,
      sendEvent: domain.daemon.conenction.send,
      id: domain.getId(),
      params: params,
    );
  }

  @override
  String prompt(String? message, {Object? defaultValue, bool hidden = false}) {
    throw UnimplementedError();
  }

  @override
  void success(String? message, {LogStyle? style}) {
    domain.daemon.conenction.send(
      DaemonEvent(
        domain: domain.name,
        event: 'loggerSuccess',
        params: {
          ...params,
          'message': message ?? '',
        },
      ),
    );
  }

  @override
  void warn(String? message, {String tag = 'WARN', LogStyle? style}) {
    domain.daemon.conenction.send(
      DaemonEvent(
        domain: domain.name,
        event: 'loggerWarn',
        params: {
          ...params,
          'message': message ?? '',
        },
      ),
    );
  }

  @override
  void write(String? message) {
    throw UnimplementedError();
  }
}

class LoggerDomainProgress implements Progress {
  LoggerDomainProgress({
    required this.message,
    required this.sendEvent,
    required this.id,
    required this.domain,
    required this.params,
  }) {
    sendEvent(
      DaemonEvent(
        domain: domain,
        event: 'progressStart',
        params: {
          ...params,
          'message': message,
          'progressId': id,
        },
      ),
    );
  }

  final String domain;

  final String message;

  final String id;

  final Map<String, dynamic> params;

  final void Function(DaemonEvent event) sendEvent;

  @override
  void cancel() {
    sendEvent(
      DaemonEvent(
        domain: domain,
        event: 'progressCancel',
        params: {
          ...params,
          'message': message,
          'progressId': id,
        },
      ),
    );
  }

  @override
  void complete([String? update]) {
    sendEvent(
      DaemonEvent(
        domain: domain,
        event: 'progressComplete',
        params: {
          ...params,
          'message': message,
          'progressId': id,
        },
      ),
    );
  }

  @override
  void fail([String? update]) {
    sendEvent(
      DaemonEvent(
        domain: domain,
        event: 'progressFail',
        params: {
          ...params,
          'message': message,
          'progressId': id,
        },
      ),
    );
  }

  @override
  void update(String update) {
    sendEvent(
      DaemonEvent(
        domain: domain,
        event: 'progressUpdate',
        params: {
          ...params,
          'message': message,
          'progressId': id,
        },
      ),
    );
  }
}
