import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dart_frog_cli/src/daemon/daemon.dart';
import 'package:test/test.dart';

Future<Process> dartFrogDaemonStart({
  required Directory directory,
}) async {
  final process = await Process.start(
    'dart_frog',
    ['daemon'],
    workingDirectory: directory.path,
    runInShell: true,
  );

  return process;
}

DaemonMessage _sdtOutLineToMessage(String rawMessage) {
  final jsonList = jsonDecode(rawMessage) as List<dynamic>;
  final jsonMap = jsonList.first as Map<String, dynamic>;
  return DaemonMessage.fromJson(jsonMap);
}

class DaemonStdioHelper {
  DaemonStdioHelper(this.daemonProcess) {
    subscription =
        daemonProcess.stdout.transform(utf8.decoder).listen(_handleStdoutLine);
  }

  final Process daemonProcess;

  var _pastMessagesBuffer = <String>[];

  late StreamSubscription<String> subscription;

  Matcher? messageMatcher;
  Completer<String>? messageCompleter;

  void _handleStdoutLine(String line) {
    log('!daemon: $line');

    final messageMatcher = this.messageMatcher;
    if (messageMatcher != null) {
      if (messageMatcher.matches(line, {})) {
        messageCompleter?.complete(line);
        _pastMessagesBuffer.clear();
        return;
      }
    }

    _pastMessagesBuffer.add(line);
  }

  void _clean() {
    messageMatcher = null;
    messageCompleter = null;
  }

  Future<DaemonEvent> awaitForDaemonEvent(
    String methodKey, {
    Duration timeout = const Duration(seconds: 1),
  }) async {
    final wrappedMatcher = isA<DaemonEvent>()
        .having((e) => '${e.domain}.${e.event}', 'is $methodKey', methodKey);

    final result = await awaitForDaemonMessage(
      wrappedMatcher,
      timeout: timeout,
    );

    return result as DaemonEvent;
  }

  Future<DaemonMessage> awaitForDaemonMessage(
    Matcher messageMatcher, {
    Duration timeout = const Duration(seconds: 1),
  }) async {
    final wrappedMatcher = _MatchMessageToStdoutLine(messageMatcher);

    final resultString = await awaitForStringMessage(
      wrappedMatcher,
      timeout: timeout,
    );

    return _sdtOutLineToMessage(resultString);
  }

  Future<String> awaitForStringMessage(
    Matcher messageMatcher, {
    Duration timeout = const Duration(seconds: 1),
  }) async {
    assert(this.messageMatcher == null, 'Already awaiting for a message');

    this.messageMatcher = messageMatcher;

    final existingItem = _pastMessagesBuffer.indexed.where((pair) {
      return messageMatcher.matches(pair.$2, {});
    }).firstOrNull;

    if (existingItem != null) {
      final (itemIndex, itemValue) = existingItem;
      _pastMessagesBuffer = _pastMessagesBuffer.skip(itemIndex + 1).toList();
      _clean();
      return itemValue;
    }

    final messageCompleter = this.messageCompleter = Completer<String>();

    final result = await Future.any(<Future<String?>>[
      messageCompleter.future,
      Future<String?>.delayed(timeout),
    ]);

    _clean();

    if (result == null) {
      throw TimeoutException('Timed out waiting for message');
    }

    return result;
  }

  Future<void> sendStringMessage(String message) async {
    daemonProcess.stdin.writeln(message);
    await daemonProcess.stdin.flush();
  }

  Future<DaemonResponse> sendDaemonRequest(
    DaemonRequest request, {
    Duration timeout = const Duration(seconds: 1),
  }) async {
    final json = jsonEncode(request.toJson());

    await sendStringMessage('[$json]');

    final wrappedMatcher = isA<DaemonResponse>().having((e) {
      return e.id;
    }, 'is ${request.id}', request.id,);

    final responseMessage = await awaitForDaemonMessage(
      wrappedMatcher,
      timeout: timeout,
    );

    return responseMessage as DaemonResponse;
  }

  void dispose() {
    subscription.cancel();
  }
}

class _MatchMessageToStdoutLine extends CustomMatcher {
  _MatchMessageToStdoutLine(Matcher matcher)
      : super('Message to stdout line', 'message', matcher);

  @override
  Object? featureValueOf(dynamic actual) {
    if (actual is String) {
      final message = _sdtOutLineToMessage(actual);
      return message;
    }
    return actual;
  }
}
