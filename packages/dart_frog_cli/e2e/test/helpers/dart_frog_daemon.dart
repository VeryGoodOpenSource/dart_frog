import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:dart_frog_cli/src/daemon/daemon.dart';
import 'package:test/test.dart';

/// Starts the dart_frog daemon in the given directory.
Future<Process> dartFrogDaemonStart() {
  return Process.start(
    'dart_frog',
    ['daemon'],
    runInShell: true,
  );
}

/// Converts a raw message from the daemon stdout
/// into a [DaemonMessage].
DaemonMessage _sdtOutLineToMessage(String rawMessage) {
  final jsonList = jsonDecode(rawMessage) as List<dynamic>;
  final jsonMap = jsonList.first as Map<String, dynamic>;
  return DaemonMessage.fromJson(jsonMap);
}

/// A helper class to interact with the daemon process
/// via its stdin and stdout.
class DaemonStdioHelper {
  DaemonStdioHelper(this.daemonProcess) {
    subscription = daemonProcess.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_handleStdoutLine);
  }

  final Process daemonProcess;

  late StreamSubscription<String> subscription;

  var _pastMessagesCache = <String>[];

  Matcher? messageMatcher;
  Completer<String>? messageCompleter;

  void _handleStdoutLine(String line) {
    final messageMatcher = this.messageMatcher;

    stdout.writeln('::debug:: <- $line');
    if (messageMatcher != null) {
      if (messageMatcher.matches(line, {})) {
        messageCompleter?.complete(line);
        _pastMessagesCache.clear();
        return;
      }
    }

    _pastMessagesCache.add(line);
  }

  void _clean() {
    messageMatcher = null;
    messageCompleter = null;
  }

  /// Awaits for a daemon event with the given [methodKey].
  Future<DaemonEvent> awaitForDaemonEvent(
    String methodKey, {
    Duration timeout = const Duration(seconds: 1),
    Matcher? withParamsThat,
  }) async {
    var wrappedMatcher = isA<DaemonEvent>()
        .having((e) => '${e.domain}.${e.event}', 'is $methodKey', methodKey);

    if (withParamsThat != null) {
      wrappedMatcher = wrappedMatcher.having(
        (e) => e.params,
        'params',
        withParamsThat,
      );
    }

    final result = await awaitForDaemonMessage(
      wrappedMatcher,
      timeout: timeout,
    );

    return result as DaemonEvent;
  }

  /// Awaits for a daemon message that matches the given [messageMatcher].
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

  /// Awaits for a string message that matches the given [messageMatcher].
  Future<String> awaitForStringMessage(
    Matcher messageMatcher, {
    Duration timeout = const Duration(seconds: 1),
  }) async {
    assert(this.messageMatcher == null, 'Already awaiting for a message');

    this.messageMatcher = messageMatcher;

    // Check if there is already a matching message in the cache.
    final existingItem = _pastMessagesCache.indexed.where((pair) {
      return messageMatcher.matches(pair.$2, {});
    }).firstOrNull;
    if (existingItem != null) {
      // if there is a matching message in the cache,
      // remove all the previous messages from the cache and
      // return the matching message.
      final (itemIndex, itemValue) = existingItem;
      _pastMessagesCache = _pastMessagesCache.skip(itemIndex + 1).toList();
      _clean();
      return itemValue;
    }

    // if there is no matching message in the cache,
    // create a completer and wait for the message to be received
    // or for the timeout to expire.

    final messageCompleter = this.messageCompleter = Completer<String>();
    final result = await Future.any(<Future<String?>>[
      messageCompleter.future,
      Future<String?>.delayed(timeout),
    ]);

    _clean();

    if (result == null) {
      throw TimeoutException('Timed out waiting for message', timeout);
    }

    return result;
  }

  /// Sends a string message to the daemon via its stdin.
  Future<void> sendStringMessage(String message) async {
    stdout.writeln('::debug:: -> $message');
    daemonProcess.stdin.writeln(message);
    await daemonProcess.stdin.flush();
  }

  /// Sends a daemon request to the daemon via its stdin.
  /// Returns the response or throws a
  /// [TimeoutException] if the timeout expires.
  Future<DaemonResponse> sendDaemonRequest(
    DaemonRequest request, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final json = jsonEncode(request.toJson());

    await sendStringMessage('[$json]');

    final wrappedMatcher = isA<DaemonResponse>().having(
      (e) => e.id,
      'id is ${request.id}',
      request.id,
    );

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

/// A matcher that matches a [DaemonMessage] to a daemon stdout line.
class _MatchMessageToStdoutLine extends CustomMatcher {
  _MatchMessageToStdoutLine(Matcher matcher)
      : super('Message to stdout line', 'message', matcher);

  @override
  Object? featureValueOf(dynamic actual) {
    if (actual is String) {
      return _sdtOutLineToMessage(actual);
    }
    return actual;
  }
}
