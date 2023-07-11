import 'package:bearer_authentication/hash_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// {@template session}
///
/// Represents a user session.
///
/// {@endtemplate}
class Session extends Equatable {
  /// {@macro session}
  const Session({
    required this.token,
    required this.userId,
    required this.expiryDate,
    required this.createdAt,
  });

  /// The session token.
  final String token;

  /// The user id.
  final String userId;

  /// The session expiration date.
  final DateTime expiryDate;

  /// The session creation date.
  final DateTime createdAt;

  @override
  List<Object?> get props => [token, userId, expiryDate, createdAt];
}

/// In memory database of sessions.
@visibleForTesting
Map<String, Session> sessionDb = {};

/// {@template session_repository}
/// Repository which manages sessions.
/// {@endtemplate}
class SessionRepository {
  /// {@macro session_repository}
  ///
  /// The [now] function is used to get the current date and time.
  const SessionRepository({
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  /// Creates a new session for the user with the given [userId].
  Future<Session> createSession(String userId) async {
    final now = _now();
    final session = Session(
      token: '${userId}_${now.toIso8601String()}'.hashValue,
      userId: userId,
      expiryDate: now.add(const Duration(days: 1)),
      createdAt: now,
    );

    sessionDb[session.token] = session;
    return session;
  }

  /// Searches and return a session by its [token].
  ///
  /// If the session is not found or is expired, returns `null`.
  Future<Session?> sessionFromToken(String token) async {
    final session = sessionDb[token];

    if (session != null && session.expiryDate.isAfter(_now())) {
      return session;
    }

    return null;
  }
}
