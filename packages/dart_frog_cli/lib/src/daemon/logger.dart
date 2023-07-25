import 'package:dart_frog_cli/src/daemon/daemon.dart';
import 'package:mason/mason.dart';

String? _boringStyle(String? m) => m;

const _boringLoggerTheme = LogTheme(
  detail: _boringStyle,
  info: _boringStyle,
  err: _boringStyle,
  warn: _boringStyle,
  alert: _boringStyle,
  success: _boringStyle,
);

/// {@template daemon_logger}
/// A [Logger] that emits daemon messages instead of
/// printing them to stdout.
///
/// If any user interaction method is called, the logger will
/// throw an [UnsupportedError].
/// {@endtemplate}
class DaemonLogger implements Logger {
  /// {@macro daemon_logger}
  DaemonLogger({
    required this.domain,
    required this.params,
    required this.sendEvent,
    required this.idGenerator,
  });

  /// The domain to send log messages to.
  final String domain;

  /// A function to send daemon events.
  void Function(DaemonEvent event) sendEvent;

  /// The parameters to send with each log message.
  final Map<String, dynamic> params;

  /// The ID generator to assign ids to progress instances.
  final String Function() idGenerator;

  final _queue = <String?>[];

  @override
  LogTheme get theme => _boringLoggerTheme;

  @override
  Level level = Level.info;

  @override
  ProgressOptions progressOptions = const ProgressOptions(
    animation: ProgressAnimation(frames: ['']),
  );

  @override
  void alert(String? message, {LogStyle? style}) {
    sendEvent(
      DaemonEvent(
        domain: domain,
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
  }) =>
      _throwUnsupported();

  @override
  T chooseOne<T extends Object?>(
    String? message, {
    required List<T> choices,
    T? defaultValue,
    String Function(T choice)? display,
  }) =>
      _throwUnsupported();

  @override
  bool confirm(String? message, {bool defaultValue = false}) =>
      _throwUnsupported();

  @override
  void delayed(String? message) => _queue.add(message);

  @override
  void detail(String? message, {LogStyle? style}) {
    sendEvent(
      DaemonEvent(
        domain: domain,
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
    sendEvent(
      DaemonEvent(
        domain: domain,
        event: 'loggerError',
        params: {
          ...params,
          'message': message ?? '',
        },
      ),
    );
  }

  @override
  void flush([void Function(String?)? print]) {
    final writeln = print ?? info;
    for (final message in _queue) {
      writeln(message);
    }
    _queue.clear();
  }

  @override
  void info(String? message, {LogStyle? style}) {
    sendEvent(
      DaemonEvent(
        domain: domain,
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
    return DaemonProgress(
      domain: domain,
      message: message,
      sendEvent: sendEvent,
      id: idGenerator(),
      params: params,
    );
  }

  @override
  String prompt(String? message, {Object? defaultValue, bool hidden = false}) {
    _throwUnsupported();
  }

  @override
  void success(String? message, {LogStyle? style}) {
    sendEvent(
      DaemonEvent(
        domain: domain,
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
    sendEvent(
      DaemonEvent(
        domain: domain,
        event: 'loggerWarning',
        params: {
          ...params,
          'message': message ?? '',
        },
      ),
    );
  }

  @override
  void write(String? message) {
    sendEvent(
      DaemonEvent(
        domain: domain,
        event: 'loggerWrite',
        params: {
          ...params,
          'message': message ?? '',
        },
      ),
    );
  }
}

/// {@template daemon_progress}
/// A [Progress] that sends messages to the daemon instead of
/// printing them to the console.
/// {@endtemplate}
class DaemonProgress implements Progress {
  /// {@macro daemon_progress}
  DaemonProgress({
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

  /// The domain to send progress messages to.
  final String domain;

  /// The message to display for the progress.
  final String message;

  /// The ID of the progress instance.
  final String id;

  /// The parameters to send with each progress message.
  final Map<String, dynamic> params;

  /// The function to send events to the daemon.
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

Never _throwUnsupported() {
  throw UnsupportedError('Cannot call user interaction methods on daemon');
}
