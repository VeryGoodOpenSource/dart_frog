---
sidebar_position: 6
title: 🔑 Security Context
---

# Security Context 🔑

By default, Dart Frog uses the insecure HTTP protocol. To enable the secure HTTPS protocol, you must pass a `SecurityContext` to the `serve` method in a [custom entrypoint](/docs/advanced/custom_entrypoint):

```dart
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  final chain = Platform.script.resolve('certificates/server_chain.pem').toFilePath();
  final key = Platform.script.resolve('certificates/server_key.pem').toFilePath();

  final securityContext = SecurityContext()
    ..useCertificateChain(chain)
    ..usePrivateKey(key, password: 'VeryGoodPassword');

  return serve(handler, ip, port, securityContext: securityContext);
}
```

For more information about SSL certificates and the `SecurityContext`, see the [`dart:io` documentation](https://api.flutter.dev/flutter/dart-io/SecurityContext-class.html).
