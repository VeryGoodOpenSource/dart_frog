import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:web_socket_counter/counter/counter.dart';

Future<Response> onRequest(RequestContext context) async {
  final handler = webSocketHandler(
    (channel, protocol) {
      final cubit = context.read<CounterCubit>()..subscribe(channel);

      channel.sink.add('${cubit.state}');

      channel.stream.listen(
        (event) {
          switch ('$event'.toMessage()) {
            case Message.increment:
              cubit.increment();
            case Message.decrement:
              cubit.decrement();
            case null:
              break;
          }
        },
        onDone: () => cubit.unsubscribe(channel),
      );
    },
  );

  return handler(context);
}

extension on String {
  Message? toMessage() {
    for (final message in Message.values) {
      if (this == message.value) {
        return message;
      }
    }
    return null;
  }
}
