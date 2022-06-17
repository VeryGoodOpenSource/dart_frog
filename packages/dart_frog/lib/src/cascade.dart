part of '_internal.dart';

/// {@template cascade}
/// A class that supports calling multiple handlers
/// in sequence and returns the first acceptable response.
///
/// By default, a response is considered acceptable if it has a status other
/// than 404 or 405; other statuses indicate that the handler understood the
/// request.
///
/// If all handlers return unacceptable responses, the final response will be
/// returned.
///
/// ```dart
/// final handler = Cascade()
///   .add(staticAssetHandler)
///   .add(router)
///   .handler;
/// ```
/// {@endtemplate}
class Cascade {
  /// {@macro cascade}
  Cascade({
    Iterable<int>? statusCodes,
    bool Function(Response)? shouldCascade,
  }) : this._(
          shelf.Cascade(
            statusCodes: statusCodes,
            shouldCascade: shouldCascade != null
                ? (response) => shouldCascade(Response._(response))
                : null,
          ),
        );

  Cascade._(this._cascade);

  final shelf.Cascade _cascade;

  /// Returns a new [Cascade] instance with the [handler] added to the end.
  ///
  /// The provided [handler] will only be called if all previous
  /// handlers in the cascade return unacceptable responses.
  Cascade add(Handler handler) {
    return Cascade._(_cascade.add(toShelfHandler(handler)));
  }

  /// Exposes this cascade as a single handler.
  ///
  /// This handler will call each inner handler in the cascade until one returns
  /// an acceptable response, and return that. If no inner handlers return an
  /// acceptable response, this will return the final response.
  Handler get handler => fromShelfHandler(_cascade.handler);
}
