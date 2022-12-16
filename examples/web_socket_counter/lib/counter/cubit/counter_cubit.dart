import 'package:broadcast_bloc/broadcast_bloc.dart';

/// {@template counter_cubit}
/// A cubit which manages the value of a count.
/// {@endtemplate}
class CounterCubit extends BroadcastCubit<int> {
  /// {@macro counter_cubit}
  CounterCubit() : super(0);

  /// Increment the current state.
  void increment() => emit(state + 1);

  /// Decrement the current state.
  void decrement() => emit(state - 1);
}
