import 'dart:async';

import 'package:dart_frog/dart_frog.dart';

final _cache = <Type, Object>{};

/// Removes the cached values for all providers.
void resetProviders() => _cache.clear();

/// Removes the cached value for the provided value of type [T].
void resetProvider<T>() => _cache.remove(T);

/// Provides an object to the current handler by calling [create].
///
/// If [lazy] is `true`, [create] will be called only when performing
/// a lookup via `context.read`.
/// If [lazy] is `false`, [create] will be called immediately when
/// an incoming request is received regardless of if a lookup is performed.
///
/// By default all providers are [lazy], meaning [create] is called on demand.
///
/// {@template provider_cache}
/// If [cache] is `true`, [create] will only be called once and the result
/// will be cached for the lifetime of the application.
/// If [cache] is `false`, [create] will be called multiple times and
/// the provided object will be recomputed.
///
/// By default providers cache, meaning the provided object won't be recomputed.
/// {@endtemplate}
///
/// ```dart
/// Handler middleware(Handler handler) {
///  return handler.use(provider<String>((_) => 'Hello World!'));
/// }
/// ```
Middleware provider<T extends Object>(
  T Function(RequestContext context) create, {
  bool cache = true,
  bool lazy = true,
}) {
  T _create(RequestContext context) {
    return cache ? _memo<T>(() => create(context)) : create(context);
  }

  return (handler) {
    return (context) {
      if (lazy) return handler(context.provide(() => _create(context)));
      final value = _create(context);
      return handler(context.provide(() => value));
    };
  };
}

/// Provide a `Future<T>` to the current handler by calling [create].
/// [create] will be called when an incoming request is received.
///
/// {@macro provider_cache}
/// ```dart
/// Handler middleware(Handler handler) {
///  return handler.use(
///    futureProvider<String>((_) async => 'Hello World!'),
///  );
/// }
/// ```
Middleware futureProvider<T extends Object>(
  Future<T> Function(RequestContext context) create, {
  bool cache = true,
}) {
  Future<T> _create(RequestContext context) async {
    return cache ? _asyncMemo<T>(() => create(context)) : create(context);
  }

  return (handler) {
    return (context) async {
      final value = await _create(context);
      return handler(context.provide<T>(() => value));
    };
  };
}

T _memo<T extends Object>(T Function() create) {
  final cachedValue = _cache[T] as T?;
  if (cachedValue != null) return cachedValue;
  final value = create();
  return _cache[T] = value;
}

Future<T> _asyncMemo<T extends Object>(Future<T> Function() create) async {
  final cachedValue = _cache[T] as T?;
  if (cachedValue != null) return cachedValue;
  final value = await create();
  return _cache[T] = value;
}
