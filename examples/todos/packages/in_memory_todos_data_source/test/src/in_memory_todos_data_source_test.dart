import 'package:in_memory_todos_data_source/in_memory_todos_data_source.dart';
import 'package:test/test.dart';

void main() {
  group('InMemoryTodosDataSource', () {
    late TodosDataSource dataSource;

    setUp(() {
      dataSource = InMemoryTodosDataSource();
    });

    group('create', () {
      test('returns the newly created todo', () async {
        final todo = Todo(title: 'title');

        final createdTodo = await dataSource.create(todo);

        expect(createdTodo.id, isNotNull);
        expect(createdTodo.title, equals(todo.title));
        expect(createdTodo.description, isEmpty);
        expect(createdTodo.isCompleted, isFalse);
      });
    });

    group('readAll', () {
      test('returns an empty list when there are no todos', () {
        expect(dataSource.readAll(), completion(isEmpty));
      });

      test('returns a populated list when there are todos', () async {
        final todo = Todo(title: 'title');

        final createdTodo = await dataSource.create(todo);

        expect(dataSource.readAll(), completion(equals([createdTodo])));
      });
    });

    group('read', () {
      test('return null when todo does not exist', () {
        expect(dataSource.read('id'), completion(isNull));
      });

      test('returns a todo when it exists', () async {
        final todo = Todo(title: 'title');

        final createdTodo = await dataSource.create(todo);

        expect(
          dataSource.read(createdTodo.id!),
          completion(equals(createdTodo)),
        );
      });
    });

    group('update', () {
      test('returns updated todo', () async {
        final todo = Todo(title: 'title');
        final updatedTodo = Todo(title: 'new title');

        final createdTodo = await dataSource.create(todo);

        final newTodo = await dataSource.update(createdTodo.id!, updatedTodo);

        expect(dataSource.readAll(), completion(equals([newTodo])));
        expect(newTodo.id, equals(todo.id));
        expect(newTodo.title, equals(updatedTodo.title));
        expect(newTodo.description, equals(todo.description));
        expect(newTodo.isCompleted, equals(todo.isCompleted));
      });
    });

    group('delete', () {
      test('removes the todo', () async {
        final todo = Todo(title: 'title');

        final createdTodo = await dataSource.create(todo);

        await dataSource.delete(createdTodo.id!);

        expect(dataSource.readAll(), completion(isEmpty));
      });
    });
  });
}
