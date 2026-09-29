import '../../../../core/usecase/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/dashboard_repository.dart';

/// Field errors from [UpdateProfile.validate]; null means the field is fine.
class ProfileErrors {
  const ProfileErrors({this.firstName, this.lastName, this.email});

  final String? firstName;
  final String? lastName;
  final String? email;

  bool get isEmpty => firstName == null && lastName == null && email == null;
}

/// Thrown by [UpdateProfile] when the input can't be saved.
class ProfileValidationException implements Exception {
  const ProfileValidationException(this.errors);

  final ProfileErrors errors;
}

/// Changes the user's name and email. The budget is left as it is.
class UpdateProfile implements UseCase<void, UserProfile> {
  const UpdateProfile(this._repository);

  static const int maxNameLength = 30;

  // Deliberately loose: something@something.something.
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final DashboardRepository _repository;

  static ProfileErrors validate({
    required String firstName,
    required String lastName,
    required String email,
  }) {
    String? name(String value, {required bool required}) {
      final v = value.trim();
      if (required && v.isEmpty) return 'First name is required';
      if (v.length > maxNameLength) {
        return 'Keep it under $maxNameLength characters';
      }
      return null;
    }

    final e = email.trim();
    return ProfileErrors(
      firstName: name(firstName, required: true),
      lastName: name(lastName, required: false),
      email: e.isEmpty
          ? 'Email is required'
          : _email.hasMatch(e)
          ? null
          : 'Enter a valid email',
    );
  }

  @override
  Future<void> call(UserProfile profile) {
    final errors = validate(
      firstName: profile.firstName,
      lastName: profile.lastName,
      email: profile.email,
    );
    if (!errors.isEmpty) throw ProfileValidationException(errors);
    return _repository.updateProfile(
      UserProfile(
        firstName: profile.firstName.trim(),
        lastName: profile.lastName.trim(),
        email: profile.email.trim(),
        monthlyBudget: profile.monthlyBudget,
      ),
    );
  }
}
