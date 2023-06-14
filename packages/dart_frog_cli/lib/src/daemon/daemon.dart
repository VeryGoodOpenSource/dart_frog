// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_frog_cli/src/daemon/domain/application.dart';
import 'package:dart_frog_cli/src/daemon/domain/project.dart';
import 'package:dart_frog_cli/src/daemon/protocol.dart';
import 'package:mason/mason.dart';

import 'domain/domain.dart';

const daemonVersion = '0.0.1';

class Daemon {
  Daemon(this.conenction) {
    conenction.inputStream.listen(_handleInput);
    _addDomain(DaemonDomain(this));
    _addDomain(ApplicationDomain(this));
    _addDomain(ProjectAnalyzerDomain(this));
  }

  final String version = daemonVersion;
  final DaemonConnection conenction;
  final Completer<ExitCode> _exitCodeCompleter = Completer<ExitCode>();

  Future<ExitCode> get exitCode => _exitCodeCompleter.future;
  Map<String, Domain> domains = {};

  Future<void> kill(ExitCode exitCode) async {
    await conenction.dispose();
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
    // todo: handle invalid domain
    final domain = request.method.split('.').first;
    domains[domain]!.handleRequest(request);
  }

  void _handleResponse(DaemonResponse message) {
    // todo: handle response
  }

  void _handleEvent(DaemonEvent message) {
    // todo: handle event
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
        stdout.add(utf8.encode('[${json}]\n'));
      } catch (e) {
        stdout.writeln('ops: ${message}');
      }
    });

    StreamSubscription<String>? _stdinSubscription;
    _inputStreamController
      ..onListen = () {
        _stdinSubscription = stdin.transform(utf8.decoder).listen((event) {
          try {
            // todo: this is a hack, fix this please
            final json = jsonDecode(event);
            _inputStreamController.add(DaemonMessage.fromJson(json));
          } catch (e) {
            // todo: handle invalid json
            print('ops');
            print(e);
          }
        });
      }
      ..onCancel = () {
        _stdinSubscription?.cancel();
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
        .then((value) => completer.complete(value));

    return completer.future;
  }

  @override
  Future<void> dispose() async {
    await _inputStreamController.close();
    await _outputStreamController.close();
  }
}
