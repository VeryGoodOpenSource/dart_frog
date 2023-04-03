import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:web_socket_client/web_socket_client.dart';
import 'package:web_socket_counter/counter/counter.dart';

import '../../routes/ws.dart' as route;

class _MockCounterCubit extends MockCubit<int> implements CounterCubit {}

void main() {
  late HttpServer server;

  late CounterCubit counterCubit;

  tearDown(() => server.close(force: true));

  group('GET /ws', () {
    setUp(() {
      counterCubit = _MockCounterCubit();
      when(() => counterCubit.state).thenReturn(0);
    });

    test('establishes connection and receives the initial count.', () async {
      const initialState = 42;
      when(() => counterCubit.state).thenReturn(initialState);
      server = await serve(
        (context) => route.onRequest(
          context.provide<CounterCubit>(() => counterCubit),
        ),
        InternetAddress.anyIPv4,
        0,
      );
      final socket = WebSocket(Uri.parse('ws://localhost:${server.port}'));

      await expectLater(socket.messages, emits('$initialState'));

      socket.close();
    });

    test('sending an increment message calls increment.', () async {
      server = await serve(
        (context) => route.onRequest(
          context.provide<CounterCubit>(() => counterCubit),
        ),
        InternetAddress.anyIPv4,
        0,
      );
      final socket = WebSocket(Uri.parse('ws://localhost:${server.port}'));

      await expectLater(socket.messages, emits(anything));

      socket.send(Message.increment.value);

      await untilCalled(counterCubit.increment);
      verify(counterCubit.increment).called(1);

      socket.close();
    });

    test('sending a decrement message calls decrement.', () async {
      server = await serve(
        (context) => route.onRequest(
          context.provide<CounterCubit>(() => counterCubit),
        ),
        InternetAddress.anyIPv4,
        0,
      );
      final socket = WebSocket(Uri.parse('ws://localhost:${server.port}'));

      await expectLater(socket.messages, emits(anything));

      socket.send(Message.decrement.value);

      await untilCalled(counterCubit.decrement);
      verify(counterCubit.decrement).called(1);

      socket.close();
    });

    test('ignores invalid messages.', () async {
      server = await serve(
        (context) => route.onRequest(
          context.provide<CounterCubit>(() => counterCubit),
        ),
        InternetAddress.anyIPv4,
        0,
      );
      final socket = WebSocket(Uri.parse('ws://localhost:${server.port}'));

      await expectLater(socket.messages, emits(anything));

      socket.send('invalid_message');

      verifyNever(counterCubit.increment);
      verifyNever(counterCubit.decrement);

      socket.close();
    });
  });
}
