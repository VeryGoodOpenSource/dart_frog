// Not required for test files
// ignore_for_file: prefer_const_constructors
import 'package:test/test.dart';
import 'package:todos_data_source/todos_data_source.dart';

class _TestTodosDataSource implements TodosDataSource {
  @override
  Future<Todo> create(Todo todo) => throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();

  @override
  Future<Todo?> read(String id) => throw UnimplementedError();

  @override
  Future<List<Todo>> readAll() => throw UnimplementedError();

  @override
  Future<Todo> update(String id, Todo todo) => throw UnimplementedError();
}

void main() {
  group('TodosDataSource', () {
    test('can be implemented', () {
      expect(_TestTodosDataSource(), isNotNull);
    });
  });
}
