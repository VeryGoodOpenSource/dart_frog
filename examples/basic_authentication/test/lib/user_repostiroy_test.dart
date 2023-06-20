// ignore_for_file: prefer_const_constructors

import 'package:example/user_repository.dart';
import 'package:test/test.dart';

void main() {
  const id = 'ae5deb822e0d71992900471a7199d0d95b8e7c9d05c40a8245a281fd2c1d6684';
  const password =
      '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8';
  const updatedPassword =
      '089542505d659cecbb988bb5ccff5bccf85be2dfa8c221359079aee2531298bb';

  group('UserRepository', () {
    test('can be instantiated', () {
      expect(UserRepository(), isNotNull);
    });

    test('userFromCredentials return null if no user is found', () async {
      mockUserData([]);
      final repository = UserRepository();
      final user = await repository.userFromCredentials('testuser', 'password');

      expect(user, isNull);
    });

    test('userFromCredentials return null if password is incorrect', () async {
      mockUserData([
        User(
          id: id,
          name: 'Test User',
          username: 'testuser',
          password: password,
        ),
      ]);
      final repository = UserRepository();
      final user = await repository.userFromCredentials('testuser', 'wrong');

      expect(user, isNull);
    });

    test('userFromCredentials return user if password is correct', () async {
      mockUserData([
        User(
          id: id,
          name: 'Test User',
          username: 'testuser',
          password: password,
        ),
      ]);

      final repository = UserRepository();
      final user = await repository.userFromCredentials('testuser', 'password');

      expect(
        user,
        equals(
          User(
            id: id,
            name: 'Test User',
            username: 'testuser',
            password: password,
          ),
        ),
      );
    });

    test('createUser adds a new user, returning its id', () async {
      mockUserData([]);
      final repository = UserRepository();
      final returnedId = await repository.createUser(
        name: 'Test User',
        username: 'testuser',
        password: 'password',
      );

      expect(returnedId, equals(id));

      expect(
        getDb(),
        equals([
          User(
            id: id,
            name: 'Test User',
            username: 'testuser',
            password: password,
          ),
        ]),
      );
    });

    test('deleteUser deletes a user', () async {
      mockUserData([
        User(
          id: id,
          name: 'Test User',
          username: 'testuser',
          password: password,
        ),
      ]);
      final repository = UserRepository();
      await repository.deleteUser(id);

      expect(getDb(), isEmpty);
    });

    test('updateUser updates the user on the db', () async {
      mockUserData([
        User(
          id: id,
          name: 'Test User',
          username: 'testuser',
          password: password,
        ),
      ]);
      final repository = UserRepository();
      await repository.updateUser(
        id: id,
        name: 'New Name',
        username: 'newusername',
        password: 'newpassword',
      );

      expect(
        getDb(),
        equals([
          User(
            id: id,
            name: 'New Name',
            username: 'newusername',
            password: updatedPassword,
          ),
        ]),
      );
    });

    test('updateUser can update just the name', () async {
      mockUserData([
        User(
          id: id,
          name: 'Test User',
          username: 'testuser',
          password: password,
        ),
      ]);
      final repository = UserRepository();
      await repository.updateUser(
        id: id,
        name: 'New Name',
        username: null,
        password: null,
      );

      expect(
        getDb(),
        equals([
          User(
            id: id,
            name: 'New Name',
            username: 'testuser',
            password: password,
          ),
        ]),
      );
    });

    test('updateUser can update just the username', () async {
      mockUserData([
        User(
          id: id,
          name: 'Test User',
          username: 'testuser',
          password: password,
        ),
      ]);
      final repository = UserRepository();
      await repository.updateUser(
        id: id,
        name: null,
        username: 'newusername',
        password: null,
      );

      expect(
        getDb(),
        equals([
          User(
            id: id,
            name: 'Test User',
            username: 'newusername',
            password: password,
          ),
        ]),
      );
    });

    test('updateUser can update just the password', () async {
      mockUserData([
        User(
          id: id,
          name: 'Test User',
          username: 'testuser',
          password: password,
        ),
      ]);
      final repository = UserRepository();
      await repository.updateUser(
        id: id,
        name: null,
        username: null,
        password: 'newpassword',
      );

      expect(
        getDb(),
        equals([
          User(
            id: id,
            name: 'Test User',
            username: 'testuser',
            password: updatedPassword,
          ),
        ]),
      );
    });
  });
}
