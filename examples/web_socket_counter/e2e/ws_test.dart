import 'package:test/test.dart';
import 'package:web_socket_client/web_socket_client.dart';
import 'package:web_socket_counter/counter/models/message.dart';

void main() {
  group('E2E', () {
    test('establishes connection and receives the initial count.', () async {
      final socket = WebSocket(Uri.parse('ws://localhost:8080/ws'));
      await expectLater(socket.messages, emits('0'));
      socket.close();
    });

    test('sending an increment message increases the count by 1', () async {
      final socket = WebSocket(Uri.parse('ws://localhost:8080/ws'));
      await expectLater(socket.messages, emits('0'));
      socket.send(Message.increment.value);
      await expectLater(socket.messages, emits('1'));
      socket.close();
    });

    test('sending a decrement message decreases the count by 1', () async {
      final socket = WebSocket(Uri.parse('ws://localhost:8080/ws'));
      await expectLater(socket.messages, emits('1'));
      socket.send(Message.decrement.value);
      await expectLater(socket.messages, emits('0'));
      socket.close();
    });
  });
}
