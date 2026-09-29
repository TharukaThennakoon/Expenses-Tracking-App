import 'dart:async';

import 'package:expenses_tracking_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:expenses_tracking_app/features/auth/domain/entities/auth_user.dart';

/// Test stand-in for Firebase Auth, with a demo account.
class InMemoryAuthDataSource implements AuthDataSource {
  InMemoryAuthDataSource();

  /// Signed in by most widget tests.
  static const String demoEmail = 'john@example.com';
  static const String demoPassword = 'password123';

  final Map<String, ({String fullName, String password})> _accounts = {
    demoEmail: (fullName: 'John Nethmina', password: demoPassword),
  };

  AuthUser? _current;

  final _changes = StreamController<AuthUser?>.broadcast(sync: true);

  @override
  Future<AuthUser?> currentUser() async => _current;

  @override
  Stream<AuthUser?> watchCurrentUser() => Stream.multi((listener) {
    listener.add(_current);
    final subscription = _changes.stream.listen(listener.add);
    listener.onCancel = subscription.cancel;
  });

  void _setCurrent(AuthUser? user) {
    _current = user;
    _changes.add(user);
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final account = _accounts[email];
    if (account == null || account.password != password) {
      // Same message for both, so it doesn't reveal which emails exist.
      throw const AuthException('Incorrect email or password');
    }
    final user = AuthUser(email: email, fullName: account.fullName);
    _setCurrent(user);
    return user;
  }

  @override
  Future<AuthUser> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (_accounts.containsKey(email)) {
      throw const AuthException(
        'An account with this email already exists',
        field: AuthField.email,
      );
    }
    _accounts[email] = (fullName: fullName, password: password);
    final user = AuthUser(email: email, fullName: fullName);
    _setCurrent(user);
    return user;
  }

  /// Nothing to send; there's no inbox behind the mock.
  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async => _setCurrent(null);
}
