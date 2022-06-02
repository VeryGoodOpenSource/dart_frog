import 'package:meta/meta.dart';
import 'package:test/test.dart';

@isTest
void testServer(String name, Future<void> Function(String host) func) {
  test(
    name,
    () async => func('http://localhost:8080'),
    timeout: _defaultTimeout,
  );
}

const _defaultTimeout = Timeout(Duration(seconds: 3));
