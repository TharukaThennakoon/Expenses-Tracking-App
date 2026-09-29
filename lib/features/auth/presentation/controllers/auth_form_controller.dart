import 'package:flutter/foundation.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/auth_usecases.dart';

/// Shared state for the sign-in and sign-up forms: per-field errors, a
/// form-level error and a busy flag.
abstract class AuthFormController extends ChangeNotifier {
  final Map<AuthField, String> _fieldErrors = {};
  String? _formError;
  bool _isBusy = false;

  bool get isBusy => _isBusy;
  String? get formError => _formError;
  String? errorFor(AuthField field) => _fieldErrors[field];

  /// Clears a field's error once the user edits it.
  void clearError(AuthField field) {
    if (_fieldErrors.remove(field) == null && _formError == null) return;
    _formError = null;
    notifyListeners();
  }

  /// Runs [action]; returns true on success, otherwise records the error.
  Future<bool> run(Future<void> Function() action) async {
    if (_isBusy) return false;
    _isBusy = true;
    _fieldErrors.clear();
    _formError = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      if (e.field case final field?) {
        _fieldErrors[field] = e.message;
      } else {
        _formError = e.message;
      }
      return false;
    } catch (_) {
      _formError = 'Something went wrong. Try again.';
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  /// Shows [errors] (null values are skipped) without calling the backend.
  @protected
  bool setFieldErrors(Map<AuthField, String?> errors) {
    _fieldErrors
      ..clear()
      ..addAll({
        for (final MapEntry(:key, :value) in errors.entries) key: ?value,
      });
    _formError = null;
    notifyListeners();
    return _fieldErrors.isEmpty;
  }
}

class SignInController extends AuthFormController {
  SignInController({required this._signIn, required this._sendPasswordReset});

  final SignIn _signIn;
  final SendPasswordReset _sendPasswordReset;

  Future<bool> submit({required String email, required String password}) {
    final valid = setFieldErrors({
      AuthField.email: AuthValidators.email(email),
      AuthField.password: password.isEmpty ? 'Password is required' : null,
    });
    if (!valid) return Future.value(false);
    return run(() => _signIn(SignInParams(email: email, password: password)));
  }

  /// Emails a reset link to the address in the email field.
  Future<bool> sendPasswordReset({required String email}) {
    final valid = setFieldErrors({
      AuthField.email: email.trim().isEmpty
          ? 'Enter your email to reset your password'
          : AuthValidators.email(email),
    });
    if (!valid) return Future.value(false);
    return run(() => _sendPasswordReset(email));
  }
}

class SignUpController extends AuthFormController {
  SignUpController({required this._signUp});

  final SignUp _signUp;

  Future<bool> submit({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    final valid = setFieldErrors({
      AuthField.fullName: AuthValidators.fullName(fullName),
      AuthField.email: AuthValidators.email(email),
      AuthField.password: AuthValidators.newPassword(password),
      AuthField.confirmPassword: AuthValidators.confirmPassword(
        password,
        confirmPassword,
      ),
    });
    if (!valid) return Future.value(false);
    return run(
      () => _signUp(
        SignUpParams(
          fullName: fullName,
          email: email,
          password: password,
          confirmPassword: confirmPassword,
        ),
      ),
    );
  }
}
