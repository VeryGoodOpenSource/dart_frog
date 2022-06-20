import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('createStaticFileHandler', () {
    test('serves static files', () async {
      const port = 3003;
      final tempDir = Directory.systemTemp.createTempSync();

      const messageContents = 'hello world';
      File(
        path.join(tempDir.path, 'message.txt'),
      ).writeAsStringSync(messageContents);

      final profileContents = json.encode(
        <String, dynamic>{'name': 'dash', 'age': 42, 'lovesDart': true},
      );
      File(
        path.join(tempDir.path, 'profile.json'),
      ).writeAsStringSync(profileContents);

      final server = await serve(
        createStaticFileHandler(path: tempDir.path),
        'localhost',
        port,
      );

      final messageResponse = await http.get(
        Uri.parse('http://localhost:$port/message.txt'),
      );
      expect(messageResponse.statusCode, equals(HttpStatus.ok));
      expect(messageResponse.body, equals(messageContents));

      final profileResponse = await http.get(
        Uri.parse('http://localhost:$port/profile.json'),
      );
      expect(profileResponse.statusCode, equals(HttpStatus.ok));
      expect(profileResponse.body, equals(profileContents));

      final notFoundResponse = await http.get(
        Uri.parse('http://localhost:$port/not-found'),
      );
      expect(notFoundResponse.statusCode, equals(HttpStatus.notFound));

      await server.close();
      tempDir.delete(recursive: true).ignore();
    });
  });
}
