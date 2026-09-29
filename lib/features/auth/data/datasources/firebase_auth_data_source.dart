import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/auth_user.dart';
import 'auth_data_source.dart';

/// Accounts in Firebase Authentication (email and password).
///
/// Firebase keeps the user signed in across restarts.
class FirebaseAuthDataSource implements AuthDataSource {
  FirebaseAuthDataSource([FirebaseAuth? auth])
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Future<AuthUser?> currentUser() async => _toAuthUser(_auth.currentUser);

  /// [FirebaseAuth.userChanges] rather than `authStateChanges`, so the name
  /// set just after sign-up comes through too.
  @override
  Stream<AuthUser?> watchCurrentUser() => _auth.userChanges().map(_toAuthUser);

  @override
  Future<AuthUser> signIn({required String email, required String password}) =>
      _guard(() async {
        final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return _toAuthUser(credential.user)!;
      });

  @override
  Future<AuthUser> signUp({
    required String fullName,
    required String email,
    required String password,
  }) => _guard(() async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user!.updateDisplayName(fullName);
    // The local User object doesn't pick up the new name by itself.
    return AuthUser(email: email, fullName: fullName);
  });

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email));

  @override
  Future<void> signOut() => _auth.signOut();

  static AuthUser? _toAuthUser(User? user) => user == null
      ? null
      : AuthUser(email: user.email ?? '', fullName: user.displayName ?? '');

  /// Turns Firebase errors into messages the forms can show.
  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw _toAuthException(e);
    }
  }

  static AuthException _toAuthException(FirebaseAuthException e) =>
      switch (e.code) {
        // Same message for all, so it doesn't reveal which emails exist.
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' => const AuthException('Incorrect email or password'),
        'invalid-email' => const AuthException(
          'Enter a valid email',
          field: AuthField.email,
        ),
        'email-already-in-use' => const AuthException(
          'An account with this email already exists',
          field: AuthField.email,
        ),
        'weak-password' => const AuthException(
          'Choose a stronger password',
          field: AuthField.password,
        ),
        'user-disabled' => const AuthException(
          'This account has been disabled',
        ),
        'too-many-requests' => const AuthException(
          'Too many attempts. Wait a moment and try again.',
        ),
        'network-request-failed' => const AuthException(
          'No connection. Check your internet and try again.',
        ),
        'operation-not-allowed' => const AuthException(
          'Email sign-in is turned off for this app',
        ),
        _ => AuthException(e.message ?? 'Something went wrong. Try again.'),
      };
}
