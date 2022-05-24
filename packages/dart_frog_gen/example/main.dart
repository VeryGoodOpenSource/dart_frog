// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dart_frog_gen/dart_frog_gen.dart';

void main() {
  final routeConfiguration = buildRouteConfiguration(Directory.current);
  print(routeConfiguration);
}
