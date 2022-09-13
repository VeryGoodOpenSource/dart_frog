// Copyright 2019 Google LLC
// Copyright 2022 Very Good Ventures
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@TestOn('vm')

import 'dart:async';

import 'package:dart_frog/dart_frog.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  group('create web socket', () {
    test('upgrade http to websocket', () async {
      final completer = Completer<void>();
      const port = 3003;

      final server = await serve(
        (context) => upgradeToWebSocket(context, (socket) {
          socket.listen((data) {
            if (data == 'ping') {
              socket.send('pong');
            }
          });
        }),
        'localhost',
        port,
      );

      final webSocket = WebSocketChannel.connect(
        Uri.parse('ws://localhost:$port/'),
      );

      webSocket.sink.add('ping');

      var response = '';

      webSocket.stream.listen((data) {
        response = data.toString();
        completer.complete();
      });

      await completer.future;

      expect(response, equals('pong'));

      await server.close();
    });

    test('upgrade http to websocket from a endpoint', () async {
      final completer = Completer<void>();
      const port = 3003;
      final app = Router()
        ..get('/ws', (RequestContext context) {
          return upgradeToWebSocket(context, (socket) {
            socket.listen((data) {
              if (data == 'ping') {
                socket.send('pong');
              }
            });
          });
        });

      final server = await serve(
        app,
        'localhost',
        port,
      );

      final webSocket = WebSocketChannel.connect(
        Uri.parse('ws://localhost:$port/ws'),
      );

      webSocket.sink.add('ping');

      var response = '';

      webSocket.stream.listen((data) {
        response = data.toString();
        completer.complete();
      });

      await completer.future;

      expect(response, equals('pong'));

      await server.close();
    });
  });
}
