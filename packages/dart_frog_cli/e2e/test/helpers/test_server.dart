import 'package:meta/meta.dart';
import 'package:test/test.dart';

@isTest
void testServer(
  String name,
  Future<void> Function(String host) func, {
  int port = 8080,
  Object? skip,
}) {
  test(
    name,
    () async => func('http://localhost:$port'),
    skip: skip,
    timeout: _defaultTimeout,
  );
}

const _defaultTimeout = Timeout(Duration(seconds: 3));
