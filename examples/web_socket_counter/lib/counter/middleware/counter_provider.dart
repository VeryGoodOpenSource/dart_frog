import 'package:dart_frog/dart_frog.dart';
import 'package:web_socket_counter/counter/counter.dart';

final _counter = CounterCubit();

/// Provides an instance of a [CounterCubit].
final counterProvider = provider<CounterCubit>((_) => _counter);
