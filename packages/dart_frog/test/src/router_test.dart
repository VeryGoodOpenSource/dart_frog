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
import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog/src/_internal.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:test/test.dart';

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  // Create a server that listens on localhost for testing
  late io.IOServer server;

  setUp(() async {
    try {
      server = await io.IOServer.bind(InternetAddress.loopbackIPv6, 0);
    } on SocketException catch (_) {
      server = await io.IOServer.bind(InternetAddress.loopbackIPv4, 0);
    }
  });

  tearDown(() => server.close());

  test('throws ArgumentError when route does not start with a slash', () {
    expect(
      () => Router()..all('hello', (RequestContext context) => Response()),
      throwsArgumentError,
    );
  });

  test('add throws ArgumentError when verb is not valid', () {
    expect(
      () => Router()
        ..add('hello', '/route', (RequestContext context) => Response()),
      throwsArgumentError,
    );
  });

  test('mount throws ArgumentError when route does not start with a slash', () {
    expect(
      () => Router()
        ..mount(
          'hello',
          (RequestContext context) => Response(body: 'not-found'),
        ),
      throwsArgumentError,
    );
  });

  test('all handler', () async {
    final context = _MockRequestContext();
    final app = Router()
      ..all('/hello/world', (RequestContext context) {
        return Response(body: 'hello');
      });

    server.mount((request) async {
      when(() => context.request).thenReturn(
        Request(request.method, request.requestedUri),
      );
      final response = await app(context);
      final body = await response.body();
      return shelf.Response(response.statusCode, body: body);
    });

    var response = await http.get(Uri.parse('${server.url}/wrong-path'));
    expect(response.statusCode, equals(HttpStatus.notFound));
    expect(response.body, equals('Route not found'));

    response = await http.get(Uri.parse('${server.url}/hello/world'));
    expect(response.statusCode, equals(HttpStatus.ok));
    expect(response.body, equals('hello'));
  });

  test('delete handler', () async {
    final context = _MockRequestContext();
    final app = Router()
      ..delete('/hello/world', (RequestContext context) {
        return Response(body: 'hello');
      });

    server.mount((request) async {
      when(() => context.request).thenReturn(
        Request(request.method, request.requestedUri),
      );
      final response = await app(context);
      final body = await response.body();
      return shelf.Response(response.statusCode, body: body);
    });

    var response = await http.get(Uri.parse('${server.url}/hello/world'));
    expect(response.statusCode, equals(HttpStatus.notFound));
    expect(response.body, equals('Route not found'));

    response = await http.delete(Uri.parse('${server.url}/hello/world'));
    expect(response.statusCode, equals(HttpStatus.ok));
    expect(response.body, equals('hello'));
  });

  test('get handler', () async {
    final context = _MockRequestContext();
    final app = Router()
      ..get('/hello/world', (RequestContext context) {
        return Response(body: 'hello');
      });

    server.mount((request) async {
      when(() => context.request).thenReturn(
        Request(request.method, request.requestedUri),
      );
      final response = await app(context);
      final body = await response.body();
      return shelf.Response(response.statusCode, body: body);
    });

    var response = await http.get(Uri.parse('${server.url}/wrong-path'));
    expect(response.statusCode, equals(HttpStatus.notFound));
    expect(response.body, equals('Route not found'));

    response = await http.head(Uri.parse('${server.url}/hello/world'));
    expect(response.statusCode, equals(HttpStatus.ok));
    expect(response.body, isEmpty);

    response = await http.get(Uri.parse('${server.url}/hello/world'));
    expect(response.statusCode, equals(HttpStatus.ok));
    expect(response.body, equals('hello'));
  });

  test('head handler', () async {
    final context = _MockRequestContext();
    final app = Router()
      ..head('/hello/world', (RequestContext context) {
        return Response();
      });

    server.mount((request) async {
      when(() => context.request).thenReturn(
        Request(request.method, request.requestedUri),
      );
      final response = await app(context);
      final body = await response.body();
      return shelf.Response(response.statusCode, body: body);
    });

    var response = await http.head(Uri.parse('${server.url}/wrong-path'));
    expect(response.statusCode, equals(HttpStatus.notFound));
    expect(response.body, isEmpty);

    response = await http.head(Uri.parse('${server.url}/hello/world'));
    expect(response.statusCode, equals(HttpStatus.ok));
    expect(response.body, isEmpty);
  });

  test('options handler', () async {
    final context = _MockRequestContext();
    final app = Router()
      ..options('/hello/world', (RequestContext context) {
        return Response(body: 'hello');
      });

    server.mount((request) async {
      when(() => context.request).thenReturn(
        Request(request.method, request.requestedUri),
      );
      final response = await app(context);
      final body = await response.body();
      return shelf.Response(response.statusCode, body: body);
    });

    final client = http.Client();
    var streamedResponse = await client.send(
      http.Request('OPTIONS', Uri.parse('${server.url}/wrong-path')),
    );
    var response = await http.Response.fromStream(streamedResponse);
    expect(response.statusCode, equals(HttpStatus.notFound));
    expect(response.body, equals('Route not found'));

    streamedResponse = await client.send(
      http.Request('OPTIONS', Uri.parse('${server.url}/hello/world')),
    );
    response = await http.Response.fromStream(streamedResponse);
    expect(response.statusCode, equals(HttpStatus.ok));
    expect(response.body, equals('hello'));

    client.close();
  });

  test('patch handler', () async {
    final context = _MockRequestContext();
    final app = Router()
      ..patch('/hello/world', (RequestContext context) {
        return Response(body: 'hello');
      });

    server.mount((request) async {
      when(() => context.request).thenReturn(
        Request(request.method, request.requestedUri),
      );
      final response = await app(context);
      final body = await response.body();
      return shelf.Response(response.statusCode, body: body);
    });

    var response = await http.get(Uri.parse('${server.url}/hello/world'));
    expect(response.statusCode, equals(HttpStatus.notFound));
    expect(response.body, equals('Route not found'));

    response = await http.patch(Uri.parse('${server.url}/hello/world'));
    expect(response.statusCode, equals(HttpStatus.ok));
    expect(response.body, equals('hello'));
  });

  test('post handler', () async {
    final context = _MockRequestContext();
    final app = Router()
      ..post('/hello/world', (RequestContext context) {
        return Response(body: 'hello');
      });

    server.mount((request) async {
      when(() => context.request).thenReturn(
        Request(request.method, request.requestedUri),
      );
      final response = await app(context);
      final body = await response.body();
      return shelf.Response(response.statusCode, body: body);
    });

    var response = await http.get(Uri.parse('${server.url}/hello/world'));
    expect(response.statusCode, equals(HttpStatus.notFound));
    expect(response.body, equals('Route not found'));

    response = await http.post(Uri.parse('${server.url}/hello/world'));
    expect(response.statusCode, equals(HttpStatus.ok));
    expect(response.body, equals('hello'));
  });

  test('put handler', () async {
    final context = _MockRequestContext();
    final app = Router()
      ..put('/hello/world', (RequestContext context) {
        return Response(body: 'hello');
      });

    server.mount((request) async {
      when(() => context.request).thenReturn(
        Request(request.method, request.requestedUri),
      );
      final response = await app(context);
      final body = await response.body();
      return shelf.Response(response.statusCode, body: body);
    });

    var response = await http.get(Uri.parse('${server.url}/hello/world'));
    expect(response.statusCode, equals(HttpStatus.notFound));
    expect(response.body, equals('Route not found'));

    response = await http.put(Uri.parse('${server.url}/hello/world'));
    expect(response.statusCode, equals(HttpStatus.ok));
    expect(response.body, equals('hello'));
  });

  test('mount(Router)', () async {
    final context = _MockRequestContext();
    final api = Router()
      ..all('/user/<user>/info', (RequestContext request, String user) {
        return Response(body: 'Hello $user');
      });

    final app = Router()
      ..all('/hello', (RequestContext context) => Response(body: 'hello-world'))
      ..mount('/api/', api)
      ..all(
        '/<_|[^]*>',
        (RequestContext context) => Response(body: 'catch-all-handler'),
      );

    server.mount((request) async {
      when(() => context.request).thenReturn(
        Request(request.method, request.requestedUri),
      );
      final response = await app.call(context);
      final body = await response.body();
      return shelf.Response(response.statusCode, body: body);
    });

    var response = await http.get(Uri.parse('${server.url}/hello'));
    expect(response.body, equals('hello-world'));

    response = await http.get(
      Uri.parse('${server.url}/api/user/felangel/info'),
    );
    expect(response.body, equals('Hello felangel'));

    response = await http.get(
      Uri.parse('${server.url}/api/user/felangel/info-wrong'),
    );
    expect(response.body, equals('catch-all-handler'));
  });

  test('mount(Handler) with middleware', () async {
    final context = _MockRequestContext();
    final api = Router()
      ..all('/hello', (RequestContext context) {
        return Response(body: 'Hello');
      });

    Handler middleware(Handler handler) {
      return (context) {
        if (context.request.url.queryParameters.containsKey('ok')) {
          return Response(body: 'middleware');
        }
        return handler(context);
      };
    }

    final app = Router()
      ..mount(
        '/api/',
        const Pipeline().addMiddleware(middleware).addHandler(api),
      );

    server.mount((request) async {
      when(() => context.request).thenReturn(
        Request(request.method, request.requestedUri),
      );
      final response = await app.call(context);
      final body = await response.body();
      return shelf.Response(response.statusCode, body: body);
    });

    var response = await http.get(Uri.parse('${server.url}/api/hello'));
    expect(response.body, equals('Hello'));

    response = await http.get(Uri.parse('${server.url}/api/hello?ok'));
    expect(response.body, equals('middleware'));
  });

  test('mount(Router) does not require a trailing slash', () async {
    final context = _MockRequestContext();
    final api = Router()
      ..all('/', (RequestContext context) => Response(body: 'Hello World!'))
      ..all('/user/<user>/info', (RequestContext context, String user) {
        return Response(body: 'Hello $user');
      });

    final app = Router()
      ..all('/hello', (RequestContext context) {
        return Response(body: 'hello-world');
      })
      ..mount('/api', api)
      ..all('/<_|[^]*>', (RequestContext context) {
        return Response(body: 'catch-all-handler');
      });

    server.mount((request) async {
      when(() => context.request).thenReturn(
        Request(request.method, request.requestedUri),
      );
      final response = await app.call(context);
      final body = await response.body();
      return shelf.Response(response.statusCode, body: body);
    });

    var response = await http.get(Uri.parse('${server.url}/hello'));
    expect(response.body, equals('hello-world'));

    response = await http.get(Uri.parse('${server.url}/api'));
    expect(response.body, equals('Hello World!'));

    response = await http.get(Uri.parse('${server.url}/api/'));
    expect(response.body, equals('Hello World!'));

    response = await http.get(
      Uri.parse('${server.url}/api/user/felangel/info'),
    );
    expect(response.body, equals('Hello felangel'));

    response = await http.get(
      Uri.parse('${server.url}/api/user/felangel/info-wrong'),
    );
    expect(response.body, equals('catch-all-handler'));
  });

  test('can invoke custom handler if no route matches', () async {
    final context = _MockRequestContext();
    final app =
        Router(notFoundHandler: (req) => Response(body: 'Not found, but ok'))
          ..all('/hello', (RequestContext context) => Response(body: 'Hello'));

    server.mount((request) async {
      when(() => context.request).thenReturn(
        Request(request.method, request.requestedUri),
      );
      final response = await app.call(context);
      final body = await response.body();
      return shelf.Response(response.statusCode, body: body);
    });

    final response = await http.get(Uri.parse('${server.url}/hi'));
    expect(response.body, equals('Not found, but ok'));
  });

  test('can call Router.routeNotFound.body() multiple times', () async {
    final b1 = await Router.routeNotFound.body();
    expect(b1, 'Route not found');
    final b2 = await Router.routeNotFound.body();
    expect(b2, b1);
  });

  test('can call Router.routeNotFound.bytes() multiple times', () async {
    final b1 = Router.routeNotFound.bytes();
    expect(b1, emits(utf8.encode('Route not found')));
    final b2 = Router.routeNotFound.bytes();
    expect(b2, emits(utf8.encode('Route not found')));
  });

  test('can call Router.routeNotFound.copyWith()', () async {
    final response = Router.routeNotFound.copyWith(headers: {'foo': 'bar'});
    expect(response.headers['foo'], equals('bar'));
    expect(response.body(), completion(equals('Route not found')));
  });

  group('RouterEntry', () {
    void testPattern(
      String pattern, {
      Map<String, Map<String, String>> match = const {},
      List<String> notMatch = const [],
    }) {
      group('RouterEntry: "$pattern"', () {
        final r = RouterEntry('GET', pattern, () => null);
        for (final e in match.entries) {
          test('Matches "${e.key}"', () {
            expect(r.match(e.key), equals(e.value));
          });
        }
        for (final v in notMatch) {
          test('NotMatch "$v"', () {
            expect(r.match(v), isNull);
          });
        }
      });
    }

    testPattern(
      '/hello',
      match: {
        '/hello': {},
      },
      notMatch: [
        '/not-hello',
        '/',
      ],
    );

    testPattern(
      r'/user/<user>/groups/<group|\d+>',
      match: {
        '/user/felangel/groups/42': {
          'user': 'felangel',
          'group': '42',
        },
        '/user/felangel/groups/0': {
          'user': 'felangel',
          'group': '0',
        },
        '/user/123/groups/101': {
          'user': '123',
          'group': '101',
        },
      },
      notMatch: [
        '/user/',
        '/user/felangel/groups/5-3',
        '/user/felangel/test/groups/5',
        '/user/felangeltest/groups/4/',
        '/user/felangel/groups/',
        '/not-hello',
        '/',
      ],
    );

    test('non-capture regex only', () {
      expect(
        () => RouterEntry('GET', '/users/<user|([^]*)>/info', () {}),
        throwsA(anything),
      );
    });
  });
}
