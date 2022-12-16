/// {@template message}
/// WebSocket counter messages.
/// {@endtemplate}
enum Message {
  /// An increment message.
  increment('__increment__'),

  /// A decrement message.
  decrement('__decrement__');

  /// {@macro message}
  const Message(this.value);

  /// The value of the message.
  final String value;
}
