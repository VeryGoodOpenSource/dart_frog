---
sidebar_position: 5
title: 🔑 Security Context
---

# Security Context 🔑

By default, Dart Frog starts with HTTP protocol. To run through HTTPS, you must pass the Security Context when calling `serve` from a [custom entrypoint](/docs/advanced/custom_entrypoint):

```dart
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  final chain = Platform.script.resolve('certificates/server_chain.pem').toFilePath();
  final key = Platform.script.resolve('certificates/server_key.pem').toFilePath();

  final securityContext =  SecurityContext()
    ..useCertificateChain(chain)
    ..usePrivateKey(key, password: 'dartdart');
  
  return serve(handler, ip, port, securityContext: securityContext);
}
```

More information about using SSL certificates is available in the [datr:io documentation](https://api.flutter.dev/flutter/dart-io/SecurityContext-class.html).
