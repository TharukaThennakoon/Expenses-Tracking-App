import 'dart:async';

import '../../../../core/usecase/usecase.dart';
import '../../../dashboard/domain/entities/user_profile.dart';
import '../../../dashboard/domain/repositories/dashboard_repository.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Input rules shared by the sign-in and sign-up forms.
abstract final class AuthValidators {
  static const int minPasswordLength = 8;

  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Email is required';
    return _email.hasMatch(v) ? null : 'Enter a valid email';
  }

  static String? fullName(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Full name is required';
    return v.length > 60 ? 'Keep it under 60 characters' : null;
  }

  /// Sign-up rule; sign-in only checks the password isn't empty.
  static String? newPassword(String value) => value.length < minPasswordLength
      ? 'Use at least $minPasswordLength characters'
      : null;

  static String? confirmPassword(String password, String confirm) {
    if (confirm.isEmpty) return 'Confirm your password';
    return confirm == password ? null : 'Passwords don’t match';
  }

  /// 0 (empty) to 4 (strong): length, mixed case, digits, symbols.
  static int passwordStrength(String value) {
    if (value.isEmpty) return 0;
    var score = 0;
    if (value.length >= minPasswordLength) score++;
    if (value.length >= 12) score++;
    if (RegExp(r'[a-z]').hasMatch(value) && RegExp(r'[A-Z]').hasMatch(value)) {
      score++;
    }
    if (RegExp(r'\d').hasMatch(value)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score++;
    return score.clamp(1, 4);
  }
}

class GetCurrentUser implements UseCase<AuthUser?, NoParams> {
  const GetCurrentUser(this._auth);

  final AuthRepository _auth;

  @override
  Future<AuthUser?> call(NoParams params) => _auth.currentUser();
}

/// The signed-in user as it changes. Also copies their name and email onto
/// the profile, so Home is right when the app opens already signed in.
class WatchCurrentUser implements StreamUseCase<AuthUser?, NoParams> {
  const WatchCurrentUser(this._auth, this._profiles);

  final AuthRepository _auth;
  final DashboardRepository _profiles;

  @override
  Stream<AuthUser?> call(NoParams params) =>
      _auth.watchCurrentUser().map((user) {
        // Right after sign-up the name isn't set yet; SignUp syncs it.
        if (user != null && user.fullName.isNotEmpty) {
          // In the background: choosing Home or Sign in mustn't wait on (or
          // fail with) the database. Home shows its own error if it's down.
          unawaited(_syncProfile(_profiles, user).catchError((Object _) {}));
        }
        return user;
      });
}

class SignInParams {
  const SignInParams({required this.email, required this.password});

  final String email;
  final String password;
}

/// Signs in, then shows the account's name and email on the profile.
class SignIn implements UseCase<AuthUser, SignInParams> {
  const SignIn(this._auth, this._profiles);

  final AuthRepository _auth;
  final DashboardRepository _profiles;

  @override
  Future<AuthUser> call(SignInParams params) async {
    final emailError = AuthValidators.email(params.email);
    if (emailError != null) {
      throw AuthException(emailError, field: AuthField.email);
    }
    if (params.password.isEmpty) {
      throw const AuthException(
        'Password is required',
        field: AuthField.password,
      );
    }
    final user = await _auth.signIn(
      email: params.email.trim().toLowerCase(),
      password: params.password,
    );
    await _syncProfile(_profiles, user);
    return user;
  }
}

class SignUpParams {
  const SignUpParams({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
}

/// Creates an account and signs into it.
class SignUp implements UseCase<AuthUser, SignUpParams> {
  const SignUp(this._auth, this._profiles);

  final AuthRepository _auth;
  final DashboardRepository _profiles;

  @override
  Future<AuthUser> call(SignUpParams params) async {
    final checks = <AuthField, String?>{
      AuthField.fullName: AuthValidators.fullName(params.fullName),
      AuthField.email: AuthValidators.email(params.email),
      AuthField.password: AuthValidators.newPassword(params.password),
      AuthField.confirmPassword: AuthValidators.confirmPassword(
        params.password,
        params.confirmPassword,
      ),
    };
    for (final MapEntry(key: field, value: error) in checks.entries) {
      if (error != null) throw AuthException(error, field: field);
    }
    final user = await _auth.signUp(
      fullName: params.fullName.trim(),
      email: params.email.trim().toLowerCase(),
      password: params.password,
    );
    await _syncProfile(_profiles, user);
    return user;
  }
}

/// Emails a link for choosing a new password.
class SendPasswordReset implements UseCase<void, String> {
  const SendPasswordReset(this._auth);

  final AuthRepository _auth;

  @override
  Future<void> call(String email) async {
    if (AuthValidators.email(email) case final error?) {
      throw AuthException(error, field: AuthField.email);
    }
    await _auth.sendPasswordReset(email.trim().toLowerCase());
  }
}

class SignOut implements UseCase<void, NoParams> {
  const SignOut(this._auth);

  final AuthRepository _auth;

  @override
  Future<void> call(NoParams params) => _auth.signOut();
}

/// Copies the account's name and email onto the profile (budget kept).
Future<void> _syncProfile(DashboardRepository profiles, AuthUser user) async {
  final (first, last) = user.nameParts;
  final current = await profiles.getUserProfile();
  await profiles.updateProfile(
    UserProfile(
      firstName: first,
      lastName: last,
      email: user.email,
      monthlyBudget: current.monthlyBudget,
    ),
  );
}
