import 'package:meta/meta.dart';
import 'package:test/test.dart';

@isTest
void testServer(
  String name,
  Future<void> Function(String host) func, {
  String? port = '8080',
}) async {
  test(
    name,
    () async => await func('http://localhost:$port'),
    timeout: _defaultTimeout,
  );
}

const _defaultTimeout = Timeout(Duration(seconds: 3));
