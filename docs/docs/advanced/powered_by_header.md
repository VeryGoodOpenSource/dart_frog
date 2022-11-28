---
sidebar_position: 2
title: 🔋 Powered By Header
---

# Powered By Header 🔋

By default, all Dart Frog responses include an `X-Powered-By` header:

```
X-Powered-By: Dart with package:dart_frog
```

:::info
The `X-Powered-By` header is supported in `dart_frog >=0.1.2`
:::

## Changing the `X-Powered-By` Header

The value of this header can be customized by specifying a custom `poweredByHeader` when calling `serve` from a [custom entrypoint](/docs/advanced/custom_entrypoint):

```dart
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  return serve(handler, ip, port, poweredByHeader: 'Dart Frog');
}
```

With the above changes, all responses would include the following `X-Powered-By` header:

```
X-Powered-By: Dart Frog
```

## Removing the `X-Powered-By` Header

The `X-Powered-By` header can be removed by setting the value to `null`:

```dart
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  return serve(handler, ip, port, poweredByHeader: null);
}
```
