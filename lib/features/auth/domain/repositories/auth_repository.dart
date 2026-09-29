import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  /// The signed-in user, or null.
  Future<AuthUser?> currentUser();

  /// Emits the signed-in user (or null) on listen, then on every change.
  Stream<AuthUser?> watchCurrentUser();

  /// Throws [AuthException] if the email or password is wrong.
  Future<AuthUser> signIn({required String email, required String password});

  /// Throws [AuthException] if the email is already registered.
  Future<AuthUser> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  /// Emails a reset link. Doesn't reveal whether the account exists.
  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}
