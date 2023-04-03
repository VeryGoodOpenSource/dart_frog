import 'package:dart_frog/dart_frog.dart';
import 'package:web_socket_counter/counter/counter.dart';

Handler middleware(Handler handler) => handler.use(counterProvider);
