import '../../domain/entities/auth_user.dart';

/// Where accounts live: Firebase in the app, in memory in tests.
abstract interface class AuthDataSource {
  Future<AuthUser?> currentUser();

  /// Emits the signed-in user (or null) on listen, then on every change.
  Stream<AuthUser?> watchCurrentUser();

  Future<AuthUser> signIn({required String email, required String password});

  Future<AuthUser> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}
