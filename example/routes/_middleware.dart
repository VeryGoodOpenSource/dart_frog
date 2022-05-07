import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) => logRequests()(handler);
