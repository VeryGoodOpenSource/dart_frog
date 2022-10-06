import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:todos_data_source/todos_data_source.dart';

void main() {
  group('E2E', () {
    final todo = Todo(title: 'take out trash');
    late Todo createdTodo;

    test('GET /todos returns empty list of todos.', () async {
      final response = await http.get(Uri.parse('http://localhost:8080/todos'));

      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals('[]'));
    });

    test('POST /todos creates a new todo.', () async {
      final response = await http.post(
        Uri.parse('http://localhost:8080/todos'),
        headers: {'content-type': 'application/json'},
        body: json.encode(todo.toJson()),
      );

      expect(response.statusCode, equals(HttpStatus.created));
      createdTodo = Todo.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
      expect(createdTodo.title, equals(todo.title));
      expect(createdTodo.id, isNotNull);
    });

    test('GET /todos returns newly created todos.', () async {
      final response = await http.get(Uri.parse('http://localhost:8080/todos'));

      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals(json.encode([createdTodo.toJson()])));
    });

    test('GET /todos/<id> returns newly created todo.', () async {
      final response = await http.get(
        Uri.parse('http://localhost:8080/todos/${createdTodo.id}'),
      );

      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals(json.encode(createdTodo.toJson())));
    });

    test('PUT /todos/<id> updates the existing todo.', () async {
      final updatedTodo = createdTodo.copyWith(description: 'ASAP');
      final response = await http.put(
        Uri.parse('http://localhost:8080/todos/${createdTodo.id}'),
        body: json.encode(updatedTodo.toJson()),
      );

      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals(json.encode(updatedTodo)));
    });

    test('DELETE /todos/<id> deletes the existing todo.', () async {
      final response = await http.delete(
        Uri.parse('http://localhost:8080/todos/${createdTodo.id}'),
      );

      expect(response.statusCode, equals(HttpStatus.noContent));
    });

    test('GET /todos returns an empty list of todos.', () async {
      final response = await http.get(Uri.parse('http://localhost:8080/todos'));

      expect(response.statusCode, equals(HttpStatus.ok));
      expect(response.body, equals('[]'));
    });
  });
}
