import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_frog_cli/src/daemon/daemon.dart';
import 'package:meta/meta.dart';

/// {@template daemon_connection}
/// A connection of the daemon that hooks into an mean of communication with
/// clients.
/// {@endtemplate}
///
/// See also:
/// - [DaemonStdioConnection], a connection that hooks into the stdio.
abstract interface class DaemonConnection {
  /// A stream of [DaemonMessage]s that are received from the client.
  Stream<DaemonMessage> get inputStream;

  /// A sink of [DaemonMessage]s that are to be sent to the client.
  StreamSink<DaemonMessage> get outputSink;

  /// Closes the connection and free resources.
  Future<void> dispose();
}

/// {@template daemon_stdio_connection}
/// A [DaemonConnection] that hooks into the stdio.
///
/// This is the default connection used by the daemon.
///
/// This uses JSON RPC over stdio to communicate with the client.
/// {@endtemplate}
class DaemonStdioConnection implements DaemonConnection {
  /// {@macro daemon_stdio_connection}
  DaemonStdioConnection({
    @visibleForTesting StreamSink<List<int>>? testStdout,
    @visibleForTesting Stream<List<int>>? testStdin,
  })  : _stdout = testStdout ?? stdout,
        _stdin = testStdin ?? stdin {
    _outputStreamController.stream.listen((message) {
      final json = jsonEncode(message.toJson());
      _stdout.add(utf8.encode('[$json]\n'));
    });

    StreamSubscription<DaemonMessage>? stdinSubscription;

    _inputStreamController
      ..onListen = () {
        stdinSubscription = _stdin.readMessages().listen(
          (message) {
            _inputStreamController.add(message);
          },
          onError: (dynamic error) {
            switch (error) {
              case DartFrogDaemonMessageException(message: final message):
                outputSink.add(
                  DaemonEvent(
                    domain: DaemonDomain.name,
                    event: 'protocolError',
                    params: {'message': message},
                  ),
                );
              case FormatException(message: _):
                outputSink.add(
                  const DaemonEvent(
                    domain: DaemonDomain.name,
                    event: 'protocolError',
                    params: {'message': 'Not a valid JSON'},
                  ),
                );
            }
          },
        );
      }
      ..onCancel = () {
        stdinSubscription?.cancel();
      };
  }

  final StreamSink<List<int>> _stdout;
  final Stream<List<int>> _stdin;

  late final StreamController<DaemonMessage> _inputStreamController =
      StreamController<DaemonMessage>();

  late final StreamController<DaemonMessage> _outputStreamController =
      StreamController<DaemonMessage>();

  @override
  Stream<DaemonMessage> get inputStream => _inputStreamController.stream;

  @override
  StreamSink<DaemonMessage> get outputSink => _outputStreamController.sink;

  @override
  Future<void> dispose() async {
    await _inputStreamController.close();
    await _outputStreamController.close();
  }
}

extension on Stream<List<int>> {
  Stream<DaemonMessage> readMessages() {
    return transform(utf8.decoder).transform(const LineSplitter()).map((event) {
      final json = jsonDecode(event);
      if (json case final List<dynamic> jsonList) {
        if (jsonList.elementAtOrNull(0)
            case final Map<String, dynamic> jsonMap) {
          return DaemonMessage.fromJson(jsonMap);
        }
      } else {
        throw const DartFrogDaemonMessageException(
          'Message should be placed within a JSON list',
        );
      }
      throw DartFrogDaemonMessageException('Invalid message: $event');
    });
  }
}
