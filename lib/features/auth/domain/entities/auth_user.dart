/// The signed-in account.
class AuthUser {
  const AuthUser({required this.email, required this.fullName});

  final String email;
  final String fullName;

  /// "John Nethmina" -> ("John", "Nethmina"); a single word has no last name.
  (String, String) get nameParts {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return (parts.first, parts.skip(1).join(' '));
  }
}

/// Which form field an [AuthException] is about; null means the whole form.
enum AuthField { fullName, email, password, confirmPassword }

/// A sign-in or sign-up problem the user can fix.
class AuthException implements Exception {
  const AuthException(this.message, {this.field});

  final String message;
  final AuthField? field;

  @override
  String toString() => 'AuthException($message)';
}
