// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_frog_cli/src/daemon/domain/domain.dart';
import 'package:dart_frog_cli/src/daemon/protocol.dart';
import 'package:mason/mason.dart';

export 'dev_server_runner.dart';
export 'domain/domain.dart';
export 'logger.dart';
export 'protocol.dart';
export 'route_config_monitor.dart';
export 'new_route_generator.dart';

const daemonVersion = '0.0.1';

class Daemon {
  Daemon(DaemonConnection conenction) : _conenction = conenction {
    _conenction.inputStream.listen(_handleInput);
    _addDomain(DaemonDomain(this));
    _addDomain(ApplicationDomain(this));
    _addDomain(RouteConfigDomain(this));
  }

  final String version = daemonVersion;
  final DaemonConnection _conenction;
  final Completer<ExitCode> _exitCodeCompleter = Completer<ExitCode>();

  Future<ExitCode> get exitCode => _exitCodeCompleter.future;
  Map<String, Domain> domains = {};

  Future<void> kill(ExitCode exitCode) async {
    await _conenction.dispose();
    _exitCodeCompleter.complete(exitCode);
  }

  void _addDomain(Domain domain) {
    domains[domain.name] = domain;
  }

  void _handleInput(DaemonMessage message) {
    if (message is DaemonRequest) {
      _handleRequest(message);
    } else if (message is DaemonResponse) {
      _handleResponse(message);
    } else if (message is DaemonEvent) {
      _handleEvent(message);
    }
  }

  void _handleRequest(DaemonRequest request) {
    final domainName = request.method.split('.').first;

    final domain = domains[domainName];

    if (domain == null) {
      return send(
        DaemonResponse.error(
          id: request.id,
          error: {
            'message': 'Invalid domain: $domainName',
          },
        ),
      );
    }

    domain.handleRequest(request);
  }

  void _handleResponse(DaemonResponse message) {
    // todo: handle response
  }

  void _handleEvent(DaemonEvent message) {
    // todo: handle event
  }

  void send(DaemonMessage message) {
    _conenction.send(message);
  }
}

abstract class DaemonConnection {
  DaemonConnection();

  factory DaemonConnection.fromStdio() {
    return DaemonStdioConnection();
  }

  Stream<DaemonMessage> get inputStream;

  StreamSink<DaemonMessage> get outputSink;

  void send(DaemonMessage message) {
    outputSink.add(message);
  }

  Future<void> dispose();
}

class DaemonStdioConnection extends DaemonConnection {
  DaemonStdioConnection() {
    _outputStreamController.stream.listen((message) {
      try {
        final json = jsonEncode(message.toJson());
        stdout.add(utf8.encode('[$json]\n'));
      } catch (e) {
        stdout.writeln('ops: $message');
      }
    });

    StreamSubscription<String>? stdinSubscription;
    _inputStreamController
      ..onListen = () {
        // todo: this is a hack, fix this please
        stdinSubscription = stdin.transform(utf8.decoder).listen((chunk) {
          chunk
              .split('\n')
              .where((element) => element.isNotEmpty)
              .forEach((event) {
            try {
              final json = jsonDecode(event);
              _inputStreamController.add(DaemonMessage.fromJson(json));
            } catch (e) {
              // todo: handle invalid json
              print('ops');
              print(e);
            }
          });
        });
      }
      ..onCancel = () {
        stdinSubscription?.cancel();
      };
  }

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

class DaemonProgramaticConnection extends DaemonConnection {
  DaemonProgramaticConnection();

  late final StreamController<DaemonMessage> _inputStreamController =
      StreamController<DaemonMessage>();

  late final StreamController<DaemonMessage> _outputStreamController =
      StreamController<DaemonMessage>.broadcast();

  @override
  Stream<DaemonMessage> get inputStream => _inputStreamController.stream;

  Stream<DaemonMessage> get outputStream => _outputStreamController.stream;

  Stream<DaemonResponse> get responses => _outputStreamController.stream
      .where((event) => event is DaemonResponse)
      .cast<DaemonResponse>();

  @override
  StreamSink<DaemonMessage> get outputSink => _outputStreamController.sink;

  Future<DaemonResponse> sendRequest(DaemonRequest request) {
    final completer = Completer<DaemonResponse>();
    final callId = request.id;
    _inputStreamController.add(request);
    responses
        .firstWhere((element) => element.id == callId)
        .then(completer.complete);

    return completer.future;
  }

  @override
  Future<void> dispose() async {
    await _inputStreamController.close();
    await _outputStreamController.close();
  }
}
