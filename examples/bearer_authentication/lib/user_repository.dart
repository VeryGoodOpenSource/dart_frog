import 'package:bearer_authentication/hash_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// In memory database of users.
@visibleForTesting
Map<String, User> userDb = {};

/// {@template user}
/// A User.
/// {@endtemplate}
class User extends Equatable {
  /// {@macro user}
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
  });

  /// The user's id.
  final String id;

  /// The user's name.
  final String name;

  /// The user's username.
  final String username;

  /// The user's password, in a hashed form.
  final String password;

  @override
  List<Object?> get props => [id, name, username, password];
}

/// {@template user_repository}
/// Repository which manages users.
/// {@endtemplate}
class UserRepository {
  /// Checks in the database for a user with the given [username] and
  /// [password].
  ///
  /// The received password should be in plain text, and will be hashed, so it
  /// can be compared to the stored password hash.
  Future<User?> userFromCredentials(String username, String password) async {
    final hashedPassword = password.hashValue;

    final users = userDb.values.where(
      (user) => user.username == username && user.password == hashedPassword,
    );

    if (users.isNotEmpty) {
      return users.first;
    }

    return null;
  }

  /// Searches and return a user by its [id].
  Future<User?> userFromId(String id) async {
    return userDb[id];
  }

  /// Creates a new user with the given [name], [username] and [password]
  /// (in raw format).
  Future<String> createUser({
    required String name,
    required String username,
    required String password,
  }) {
    final id = username.hashValue;

    final user = User(
      id: id,
      name: name,
      username: username,
      password: password.hashValue,
    );

    userDb[id] = user;

    return Future.value(id);
  }

  /// Deletes the user with the given [id].
  Future<void> deleteUser(String id) async {
    userDb.remove(id);
  }

  /// Updates the user with the given [id] with the given [name], [username]
  /// and [password] (in raw format).
  Future<void> updateUser({
    required String id,
    required String? name,
    required String? username,
    required String? password,
  }) async {
    final currentUser = userDb[id];

    if (currentUser == null) {
      return Future.error(Exception('User not found'));
    }

    final user = User(
      id: id,
      name: name ?? currentUser.name,
      username: username ?? currentUser.username,
      password: password?.hashValue ?? currentUser.password,
    );

    userDb[id] = user;
  }
}
