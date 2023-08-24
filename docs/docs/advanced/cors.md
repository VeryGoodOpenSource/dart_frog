---
sidebar_position: 8
title: ⚔️  Handling Cross-Origin Resource Sharing (CORS)
---

Cross-Origin Resource Sharing or CORS is a common thing that needs to be handled by backend servers.
This guide shows how the handling of CORS can be done in a Dart Frog project.

:::info
To learn more about what CORS is, check out this [helpful documentation from MDN](https://developer.mozilla.org/docs/Web/HTTP/CORS).
:::

[Shelf](https://pub.dev/packages/shelf) already has a package in its ecosystem that handles CORS.
Since Dart Frog is built on top of shelf, we can use it in Dart Frog as well. First add `shelf_cors_headers` to your project:

```bash
dart pub add shelf_cors_headers
```

Then, to allow CORS in routes, the following middleware can be created:

```dart
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart' as shelf;

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(
        fromShelfMiddleware(
          shelf.corsHeaders(
            headers: {
              shelf.ACCESS_CONTROL_ALLOW_ORIGIN: 'https://myfrontendurl.com',
            },
          ),
        ),
      );
}
```

For a full example of a Dart Frog server that handles CORS, check [Very Good Hub](https://github.com/VeryGoodOpenSource/very_good_hub/tree/main/api).
