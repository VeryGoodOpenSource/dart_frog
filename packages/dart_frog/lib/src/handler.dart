import 'dart:async';

import 'package:dart_frog/dart_frog.dart';

/// A function which handles a request via the provided [context].
typedef Handler = FutureOr<Response> Function(RequestContext context);
