import 'package:dart_frog_cli/src/daemon/daemon.dart';
import 'package:test/test.dart';

void main() {
  Matcher unsupportedErrorWithMessage(String name) {
    return isA<UnsupportedError>().having(
      (p) => p.message,
      'message',
      'Unsupported daemon logger property: $name',
    );
  }

  group('$DaemonLogger', () {
    String idGenerator() => 'id';

    final daemonEvents = <DaemonEvent>[];

    void sendEvent(DaemonEvent event) {
      daemonEvents.add(event);
    }

    tearDown(daemonEvents.clear);

    final params = <String, dynamic>{
      'meta-information1': true,
    };

    test('can be instantiated', () {
      final logger = DaemonLogger(
        domain: 'test',
        params: {},
        sendEvent: (event) {},
        idGenerator: idGenerator,
      );
      expect(logger, isNotNull);
    });

    test('alert', () {
      DaemonLogger(
        domain: 'test',
        params: params,
        sendEvent: sendEvent,
        idGenerator: idGenerator,
      ).alert('alert');

      expect(daemonEvents.length, equals(1));

      expect(
        daemonEvents.last,
        const DaemonEvent(
          domain: 'test',
          event: 'loggerAlert',
          params: {
            'meta-information1': true,
            'message': 'alert',
          },
        ),
      );
    });

    test('chooseAny', () {
      final logger = DaemonLogger(
        domain: 'test',
        params: {},
        sendEvent: sendEvent,
        idGenerator: idGenerator,
      );

      expect(
        () => logger.chooseAny('choose any of this', choices: ['oi', 'ai']),
        throwsA(unsupportedErrorWithMessage('chooseAny')),
      );
    });

    test('chooseOne', () {
      final logger = DaemonLogger(
        domain: 'test',
        params: {},
        sendEvent: sendEvent,
        idGenerator: idGenerator,
      );

      expect(
        () => logger.chooseOne('choose one of this', choices: ['oi', 'ai']),
        throwsA(unsupportedErrorWithMessage('chooseOne')),
      );
    });

    test('confirm', () {
      final logger = DaemonLogger(
        domain: 'test',
        params: {},
        sendEvent: sendEvent,
        idGenerator: idGenerator,
      );

      expect(
        () => logger.confirm('confirm this'),
        throwsA(unsupportedErrorWithMessage('confirm')),
      );
    });

    test('delayed/flush', () {
      DaemonLogger(
        domain: 'test',
        params: params,
        sendEvent: sendEvent,
        idGenerator: idGenerator,
      )
        ..delayed('delayed1')
        ..delayed('delayed2')
        ..flush();

      expect(daemonEvents.length, 2);

      expect(
        daemonEvents.first,
        const DaemonEvent(
          domain: 'test',
          event: 'loggerInfo',
          params: {
            'meta-information1': true,
            'message': 'delayed1',
          },
        ),
      );

      expect(
        daemonEvents.last,
        const DaemonEvent(
          domain: 'test',
          event: 'loggerInfo',
          params: {
            'meta-information1': true,
            'message': 'delayed2',
          },
        ),
      );
    });

    test('detail', () {
      DaemonLogger(
        domain: 'test',
        params: params,
        sendEvent: sendEvent,
        idGenerator: idGenerator,
      ).detail('detail');

      expect(daemonEvents.length, equals(1));

      expect(
        daemonEvents.last,
        const DaemonEvent(
          domain: 'test',
          event: 'loggerDetail',
          params: {
            'meta-information1': true,
            'message': 'detail',
          },
        ),
      );
    });

    test('err', () {
      DaemonLogger(
        domain: 'test',
        params: params,
        sendEvent: sendEvent,
        idGenerator: idGenerator,
      ).err('err');

      expect(daemonEvents.length, equals(1));

      expect(
        daemonEvents.last,
        const DaemonEvent(
          domain: 'test',
          event: 'loggerError',
          params: {
            'meta-information1': true,
            'message': 'err',
          },
        ),
      );
    });

    test('info', () {
      DaemonLogger(
        domain: 'test',
        params: params,
        sendEvent: sendEvent,
        idGenerator: idGenerator,
      ).info('info');

      expect(daemonEvents.length, equals(1));

      expect(
        daemonEvents.last,
        const DaemonEvent(
          domain: 'test',
          event: 'loggerInfo',
          params: {
            'meta-information1': true,
            'message': 'info',
          },
        ),
      );
    });

    test('prompt', () {
      final logger = DaemonLogger(
        domain: 'test',
        params: {},
        sendEvent: sendEvent,
        idGenerator: idGenerator,
      );

      expect(
        () => logger.prompt('prompt this'),
        throwsA(unsupportedErrorWithMessage('prompt')),
      );
    });

    test('promptAny', () {
      final logger = DaemonLogger(
        domain: 'test',
        params: {},
        sendEvent: sendEvent,
        idGenerator: idGenerator,
      );

      expect(
        () => logger.promptAny('prompt anything'),
        throwsA(unsupportedErrorWithMessage('promptAny')),
      );
    });

    test('success', () {
      DaemonLogger(
        domain: 'test',
        params: params,
        sendEvent: sendEvent,
        idGenerator: idGenerator,
      ).success('success');

      expect(daemonEvents.length, equals(1));

      expect(
        daemonEvents.last,
        const DaemonEvent(
          domain: 'test',
          event: 'loggerSuccess',
          params: {
            'meta-information1': true,
            'message': 'success',
          },
        ),
      );
    });

    test('warn', () {
      DaemonLogger(
        domain: 'test',
        params: params,
        sendEvent: sendEvent,
        idGenerator: idGenerator,
      ).warn('warn');

      expect(daemonEvents.length, equals(1));

      expect(
        daemonEvents.last,
        const DaemonEvent(
          domain: 'test',
          event: 'loggerWarning',
          params: {
            'meta-information1': true,
            'message': 'warn',
          },
        ),
      );
    });

    test('write', () {
      DaemonLogger(
        domain: 'test',
        params: params,
        sendEvent: sendEvent,
        idGenerator: idGenerator,
      ).write('write');

      expect(daemonEvents.length, equals(1));

      expect(
        daemonEvents.last,
        const DaemonEvent(
          domain: 'test',
          event: 'loggerWrite',
          params: {
            'meta-information1': true,
            'message': 'write',
          },
        ),
      );
    });
  });
}
